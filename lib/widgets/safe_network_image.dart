import 'package:flutter/material.dart';
import '../utils/image_validator.dart';

class SafeNetworkImage extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? fallbackImagePath;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeNetworkImage({
    Key? key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackImagePath,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<SafeNetworkImage> createState() => _SafeNetworkImageState();
}

class _SafeNetworkImageState extends State<SafeNetworkImage> {
  late String _currentImagePath;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _currentImagePath = ImageValidator.getValidImageUrlOrDefault(
      widget.imagePath,
      widget.fallbackImagePath,
    );
  }

  @override
  void didUpdateWidget(SafeNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _currentImagePath = ImageValidator.getValidImageUrlOrDefault(
        widget.imagePath,
        widget.fallbackImagePath,
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
    if (!ImageValidator.isValidImageUrl(_currentImagePath)) {
      return _buildErrorWidget();
    }

    if (_currentImagePath.startsWith('assets/')) {
      return Image.asset(
        _currentImagePath,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          if (!_hasError && 
              widget.fallbackImagePath != null && 
              widget.fallbackImagePath != _currentImagePath &&
              ImageValidator.isValidImageUrl(widget.fallbackImagePath)) {
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _currentImagePath = widget.fallbackImagePath!;
                  _hasError = true;
                });
              }
            });
            return _buildPlaceholder();
          }
          
          return _buildErrorWidget();
        },
      );
    } else {
      return Image.network(
        _currentImagePath,
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
              widget.fallbackImagePath != null && 
              widget.fallbackImagePath != _currentImagePath &&
              ImageValidator.isValidImageUrl(widget.fallbackImagePath)) {
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _currentImagePath = widget.fallbackImagePath!;
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
}
