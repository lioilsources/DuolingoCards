package comfyuiimage

import (
	"encoding/json"
	"reflect"
	"testing"
)

// Node IDs live in two places that must agree: the embedded workflow JSON and
// the NodeRoles struct used to inject into it. A mismatch is invisible until a
// generation run fails deep in buildWorkflow with "workflow node %q not found",
// so pair every graph with its roles here and check statically.
func TestWorkflowNodeRolesExist(t *testing.T) {
	cases := []struct {
		name  string
		graph []byte
		roles NodeRoles
	}{
		{"flux_card", defaultWorkflow, defaultNodeRoles},
		{"flux_dev", fluxDevWorkflow, FluxDevNodeRoles},
		{"pony_img2img", ponyImg2ImgWorkflow, img2ImgNodeRoles},
		{"illustrious_cn_img2img", illustriousCNWorkflow, illustriousCNNodeRoles},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			var graph map[string]json.RawMessage
			if err := json.Unmarshal(tc.graph, &graph); err != nil {
				t.Fatalf("parse workflow: %v", err)
			}

			// Walk the NodeRoles fields by name so a newly added role is covered
			// without touching this test. Only the *Node/-node-ID fields name
			// graph nodes; the Key fields name inputs on them.
			rv := reflect.ValueOf(tc.roles)
			rt := rv.Type()
			for i := 0; i < rt.NumField(); i++ {
				field := rt.Field(i)
				if field.Name == "CheckpointKey" || field.Name == "ControlNetKey" {
					continue
				}
				id := rv.Field(i).String()
				if id == "" {
					continue // role not used by this workflow
				}
				if _, ok := graph[id]; !ok {
					t.Errorf("role %s points at node %q, which is not in the graph", field.Name, id)
				}
			}
		})
	}
}

// The ControlNet graph is the one place where an injected input key ("strength",
// "end_percent") is not part of NodeRoles, so a rename in the JSON would
// silently stop the structure lock from being tuned.
func TestIllustriousControlNetGraphShape(t *testing.T) {
	var graph map[string]struct {
		ClassType string                 `json:"class_type"`
		Inputs    map[string]interface{} `json:"inputs"`
	}
	if err := json.Unmarshal(illustriousCNWorkflow, &graph); err != nil {
		t.Fatalf("parse workflow: %v", err)
	}

	roles := IllustriousControlNetNodeRoles()
	apply, ok := graph[roles.ControlApplyNode]
	if !ok {
		t.Fatalf("ControlApplyNode %q missing from graph", roles.ControlApplyNode)
	}
	if apply.ClassType != "ControlNetApplyAdvanced" {
		t.Errorf("ControlApplyNode class_type = %q, want ControlNetApplyAdvanced", apply.ClassType)
	}
	for _, key := range []string{"strength", "end_percent"} {
		if _, ok := apply.Inputs[key]; !ok {
			t.Errorf("ControlApplyNode has no %q input to inject into", key)
		}
	}

	loader, ok := graph[roles.ControlNetNode]
	if !ok {
		t.Fatalf("ControlNetNode %q missing from graph", roles.ControlNetNode)
	}
	if _, ok := loader.Inputs[roles.ControlNetKey]; !ok {
		t.Errorf("ControlNetNode has no %q input", roles.ControlNetKey)
	}

	// The structure lock only works if the sampler's conditioning comes from the
	// ControlNet apply node rather than straight from the text encoders.
	sampler, ok := graph[roles.Sampler]
	if !ok {
		t.Fatalf("Sampler node %q missing from graph", roles.Sampler)
	}
	for _, key := range []string{"positive", "negative"} {
		link, ok := sampler.Inputs[key].([]interface{})
		if !ok || len(link) != 2 {
			t.Fatalf("sampler input %q is not a node link: %v", key, sampler.Inputs[key])
		}
		if link[0] != roles.ControlApplyNode {
			t.Errorf("sampler %q comes from node %v, want ControlNet apply node %q", key, link[0], roles.ControlApplyNode)
		}
	}
}
