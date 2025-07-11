class ImageValidator {
  /// Validates if an image path is valid (local asset or URL)
  static bool isValidImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return false;
    }

    // Check if it's a local asset path
    if (imagePath.startsWith('assets/')) {
      return _isValidAssetPath(imagePath);
    }

    // Check if it's a valid URL format
    try {
      final uri = Uri.parse(imagePath);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return false;
      }
    } catch (e) {
      return false;
    }

    // Check if it's a supported image format
    final supportedFormats = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final lowerUrl = imagePath.toLowerCase();
    
    // For Unsplash URLs, they don't always end with extensions but are valid
    if (lowerUrl.contains('unsplash.com') || lowerUrl.contains('images.unsplash.com')) {
      return true;
    }

    // For other URLs, check if they end with supported formats
    return supportedFormats.any((format) => lowerUrl.contains(format));
  }

  /// Validates if an asset path has a supported image format
  static bool _isValidAssetPath(String assetPath) {
    final supportedFormats = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.jfif'];
    final lowerPath = assetPath.toLowerCase();
    return supportedFormats.any((format) => lowerPath.endsWith(format));
  }

  /// Validates if a list of image paths are all valid
  static List<String> getValidImageUrls(List<String> imagePaths) {
    return imagePaths.where((path) => isValidImageUrl(path)).toList();
  }

  /// Gets a default placeholder image path if the provided path is invalid
  static String getValidImageUrlOrDefault(String? imagePath, [String? defaultPath]) {
    if (isValidImageUrl(imagePath)) {
      return imagePath!;
    }
    
    return defaultPath ?? 'assets/images/chocolate-cake.jpg'; // Default local food image
  }
}
