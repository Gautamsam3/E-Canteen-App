import 'package:flutter/material.dart';
import '../utils/image_validator.dart';

class SafeNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? fallbackImageUrl;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackImageUrl,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<SafeNetworkImage> createState() => _SafeNetworkImageState();
}

class _SafeNetworkImageState extends State<SafeNetworkImage> {
  late String _currentImageUrl;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = ImageValidator.getValidImageUrlOrDefault(
      widget.imageUrl,
      widget.fallbackImageUrl,
    );
  }

  @override
  void didUpdateWidget(SafeNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _currentImageUrl = ImageValidator.getValidImageUrlOrDefault(
        widget.imageUrl,
        widget.fallbackImageUrl,
      );
      _hasError = false;
    }
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 40,
                color: Colors.grey[600],
              ),
              SizedBox(height: 8),
              Text(
                'Image not available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
  }

  Widget _buildPlaceholder() {
    return widget.placeholder ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (!ImageValidator.isValidImageUrl(_currentImageUrl)) {
      return _buildErrorWidget();
    }

    return Image.network(
      _currentImageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        // Try fallback image if available and not already tried
        if (!_hasError && 
            widget.fallbackImageUrl != null && 
            widget.fallbackImageUrl != _currentImageUrl &&
            ImageValidator.isValidImageUrl(widget.fallbackImageUrl)) {
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _currentImageUrl = widget.fallbackImageUrl!;
                _hasError = true;
              });
            }
          });
          return _buildPlaceholder();
        }
        
        return _buildErrorWidget();
      },
    );
  }
}
