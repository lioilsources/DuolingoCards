import 'package:flutter/material.dart';
import '../models/catalog.dart';
import '../services/api_service.dart';
import '../services/local_deck_service.dart';
import '../services/media_download_service.dart';
import '../services/iap_service.dart';
import 'deck_screen.dart';

class DeckStoreScreen extends StatefulWidget {
  final String apiBaseUrl;

  const DeckStoreScreen({
    super.key,
    required this.apiBaseUrl,
  });

  @override
  State<DeckStoreScreen> createState() => _DeckStoreScreenState();
}

class _DeckStoreScreenState extends State<DeckStoreScreen> {
  late final ApiService _apiService;
  late final LocalDeckService _localDeckService;
  late final MediaDownloadService _mediaDownloadService;
  final IAPService _iapService = IAPService();

  Catalog? _catalog;
  Set<String> _downloadedDeckIds = {};
  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _isDownloading = false;
  int _downloadProgress = 0;
  int _downloadTotal = 0;
  String? _downloadingDeckName;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(baseUrl: widget.apiBaseUrl);
    _localDeckService = LocalDeckService();
    _mediaDownloadService = MediaDownloadService();
    _initIAP();
    _loadData();
  }

  Future<void> _initIAP() async {
    await _iapService.initialize();

    _iapService.onPurchaseSuccess = (deckId, receiptData) async {
      // Download the deck after successful purchase
      await _downloadPurchasedDeck(deckId, receiptData);
      setState(() => _isPurchasing = false);
    };

    _iapService.onPurchaseError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $error')),
        );
      }
      setState(() => _isPurchasing = false);
    };

    _iapService.onPurchaseRestored = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored')),
        );
        _loadData(); // Reload to update UI
      }
    };
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final catalog = await _apiService.getCatalog();
      final downloadedIds = await _localDeckService.getDownloadedDeckIds();

      // Load IAP products for paid decks
      final paidDeckIds = catalog.decks
          .where((d) => !d.isFree)
          .map((d) => d.id)
          .toList();
      if (paidDeckIds.isNotEmpty) {
        await _iapService.loadProducts(paidDeckIds);
      }

      setState(() {
        _catalog = catalog;
        _downloadedDeckIds = downloadedIds.toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadDeck(CatalogItem item) async {
    if (!item.isFree) {
      await _purchaseDeck(item);
      return;
    }

    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0;
        _downloadTotal = 0;
        _downloadingDeckName = item.name;
      });

      final deck = await _apiService.getDeck(item.id);

      // Download media files with progress
      final deckWithLocalMedia = await _mediaDownloadService.downloadDeckMedia(
        deck,
        onProgress: (downloaded, total) {
          setState(() {
            _downloadProgress = downloaded;
            _downloadTotal = total;
          });
        },
      );

      await _localDeckService.saveDeck(deckWithLocalMedia);

      setState(() {
        _downloadedDeckIds.add(item.id);
        _isDownloading = false;
        _downloadingDeckName = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} downloaded!')),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _downloadingDeckName = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  Future<void> _purchaseDeck(CatalogItem item) async {
    if (!_iapService.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('In-App Purchases not available')),
      );
      return;
    }

    // Check if already purchased (restored)
    if (_iapService.purchasedDeckIds.contains(item.id)) {
      await _downloadPurchasedDeck(item.id, '');
      return;
    }

    setState(() => _isPurchasing = true);

    final success = await _iapService.purchaseDeck(item.id);
    if (!success) {
      setState(() => _isPurchasing = false);
    }
    // If success, the callback will handle the rest
  }

  Future<void> _downloadPurchasedDeck(String deckId, String receiptData) async {
    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0;
        _downloadTotal = 0;
        _downloadingDeckName = 'purchased deck';
      });

      // Download with receipt for server validation
      final deck = await _apiService.downloadDeck(deckId, receiptData: receiptData);

      // Download media files with progress
      final deckWithLocalMedia = await _mediaDownloadService.downloadDeckMedia(
        deck,
        onProgress: (downloaded, total) {
          setState(() {
            _downloadProgress = downloaded;
            _downloadTotal = total;
          });
        },
      );

      await _localDeckService.saveDeck(deckWithLocalMedia);

      setState(() {
        _downloadedDeckIds.add(deckId);
        _isDownloading = false;
        _downloadingDeckName = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deck downloaded!')),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _downloadingDeckName = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    await _iapService.restorePurchases();
  }

  Future<void> _openDeck(String deckId) async {
    final deck = await _localDeckService.loadDeck(deckId);
    if (deck != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DeckScreen(deck: deck),
        ),
      );
    }
  }

  Future<void> _showPreview(CatalogItem item) async {
    try {
      final preview = await _apiService.getDeckPreview(item.id);
      final localizedPrice = _iapService.getLocalizedPrice(item.id);

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => _PreviewSheet(
            preview: preview,
            item: item,
            isDownloaded: _downloadedDeckIds.contains(item.id),
            isPurchased: _iapService.purchasedDeckIds.contains(item.id),
            localizedPrice: localizedPrice,
            onDownload: () {
              Navigator.pop(context);
              _downloadDeck(item);
            },
            onOpen: () {
              Navigator.pop(context);
              _openDeck(item.id);
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load preview: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _restorePurchases,
            tooltip: 'Restore Purchases',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_isPurchasing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Processing purchase...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          if (_isDownloading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'Downloading $_downloadingDeckName...',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    if (_downloadTotal > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '$_downloadProgress / $_downloadTotal files',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: LinearProgressIndicator(
                          value: _downloadProgress / _downloadTotal,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_catalog == null || _catalog!.decks.isEmpty) {
      return const Center(child: Text('No decks available'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _catalog!.decks.length,
        itemBuilder: (context, index) {
          final item = _catalog!.decks[index];
          final isDownloaded = _downloadedDeckIds.contains(item.id);
          final isPurchased = _iapService.purchasedDeckIds.contains(item.id);
          final localizedPrice = _iapService.getLocalizedPrice(item.id);

          return _DeckCard(
            item: item,
            isDownloaded: isDownloaded,
            isPurchased: isPurchased,
            localizedPrice: localizedPrice,
            onTap: () => _showPreview(item),
            onDownload: () => _downloadDeck(item),
            onOpen: () => _openDeck(item.id),
          );
        },
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final CatalogItem item;
  final bool isDownloaded;
  final bool isPurchased;
  final String? localizedPrice;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onOpen;

  const _DeckCard({
    required this.item,
    required this.isDownloaded,
    required this.isPurchased,
    this.localizedPrice,
    required this.onTap,
    required this.onDownload,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item.languages.isNotEmpty
                        ? item.languages.first.toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.cardCount} cards',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (isDownloaded) {
      return ElevatedButton(
        onPressed: onOpen,
        child: const Text('Open'),
      );
    }

    if (isPurchased) {
      return ElevatedButton.icon(
        onPressed: onDownload,
        icon: const Icon(Icons.download),
        label: const Text('Download'),
      );
    }

    if (item.isFree) {
      return ElevatedButton.icon(
        onPressed: onDownload,
        icon: const Icon(Icons.download),
        label: const Text('Free'),
      );
    }

    return ElevatedButton.icon(
      onPressed: onDownload,
      icon: const Icon(Icons.shopping_cart),
      label: Text(localizedPrice ?? item.price),
    );
  }
}

class _PreviewSheet extends StatelessWidget {
  final DeckPreview preview;
  final CatalogItem item;
  final bool isDownloaded;
  final bool isPurchased;
  final String? localizedPrice;
  final VoidCallback onDownload;
  final VoidCallback onOpen;

  const _PreviewSheet({
    required this.preview,
    required this.item,
    required this.isDownloaded,
    required this.isPurchased,
    this.localizedPrice,
    required this.onDownload,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                preview.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${preview.totalCards} cards • ${preview.frontLanguage.toUpperCase()} → ${preview.backLanguage.toUpperCase()}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              if (preview.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(preview.description),
              ],
              const SizedBox(height: 20),
              const Text(
                'Preview:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: preview.previewCards.length,
                  itemBuilder: (context, index) {
                    final card = preview.previewCards[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          card['frontText'] as String? ?? '',
                          style: const TextStyle(fontSize: 20),
                        ),
                        subtitle: Text(card['backText'] as String? ?? ''),
                        trailing: card['reading'] != null
                            ? Text(
                                card['reading'] as String,
                                style: TextStyle(color: Colors.grey.shade500),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton() {
    if (isDownloaded) {
      return ElevatedButton(
        onPressed: onOpen,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Open Deck'),
      );
    }

    if (isPurchased) {
      return ElevatedButton.icon(
        onPressed: onDownload,
        icon: const Icon(Icons.download),
        label: const Text('Download Purchased Deck'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    }

    if (item.isFree) {
      return ElevatedButton.icon(
        onPressed: onDownload,
        icon: const Icon(Icons.download),
        label: const Text('Download Free'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onDownload,
      icon: const Icon(Icons.shopping_cart),
      label: Text('Buy for ${localizedPrice ?? item.price}'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
