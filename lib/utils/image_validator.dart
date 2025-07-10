class ImageValidator {
  /// Validates if an image URL is valid and accessible
  static bool isValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return false;
    }

    // Check if it's a valid URL format
    try {
      final uri = Uri.parse(imageUrl);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return false;
      }
    } catch (e) {
      return false;
    }

    // Check if it's a supported image format
    final supportedFormats = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final lowerUrl = imageUrl.toLowerCase();
    
    // For Unsplash URLs, they don't always end with extensions but are valid
    if (lowerUrl.contains('unsplash.com') || lowerUrl.contains('images.unsplash.com')) {
      return true;
    }

    // For other URLs, check if they end with supported formats
    return supportedFormats.any((format) => lowerUrl.contains(format));
  }

  /// Validates if a list of image URLs are all valid
  static List<String> getValidImageUrls(List<String> imageUrls) {
    return imageUrls.where((url) => isValidImageUrl(url)).toList();
  }

  /// Gets a default placeholder image URL if the provided URL is invalid
  static String getValidImageUrlOrDefault(String? imageUrl, [String? defaultUrl]) {
    if (isValidImageUrl(imageUrl)) {
      return imageUrl!;
    }
    
    return defaultUrl ?? 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500&h=400&fit=crop'; // Default food image
  }

  /// Validates and formats Unsplash URLs to ensure proper sizing
  static String formatUnsplashUrl(String imageUrl, {int width = 500, int height = 400}) {
    if (!imageUrl.contains('unsplash.com')) {
      return imageUrl;
    }

    // Remove existing size parameters
    final uri = Uri.parse(imageUrl);
    final baseUrl = '${uri.scheme}://${uri.host}${uri.path}';
    
    // Add proper sizing parameters
    return '$baseUrl?w=$width&h=$height&fit=crop';
  }
}
