class UrlSafetyUtil {
  // List of potentially suspicious TLDs
  static const List<String> _suspiciousTlds = [
    '.xyz', '.tk', '.ml', '.ga', '.cf', '.gq', '.top', '.bid', '.loan'
  ];

  // List of known URL shorteners
  static const List<String> _urlShorteners = [
    'bit.ly', 'tinyurl.com', 'goo.gl', 'ow.ly', 't.co', 
    'tiny.cc', 'is.gd', 'buff.ly', 'rebrand.ly', 'dlvr.it'
  ];

  // URL validation - returns safety status and reason
  static Map<String, dynamic> isUrlSafe(String url) {
    // Convert to lowercase for case-insensitive checks
    final lowerUrl = url.toLowerCase();
    
    // 1. Check if it's a valid URL format
    if (!_isValidUrlFormat(lowerUrl)) {
      return {
        'isSafe': false, 
        'reason': 'Invalid URL format'
      };
    }
    
    // 2. Check for HTTPS protocol (more secure)
    if (!lowerUrl.startsWith('https://')) {
      return {
        'isSafe': false, 
        'reason': 'Not using HTTPS (secure protocol)'
      };
    }

    // 3. Check for suspicious TLDs
    if (_hasSuspiciousTld(lowerUrl)) {
      return {
        'isSafe': false, 
        'reason': 'Suspicious domain extension'
      };
    }
    
    // 4. Check for URL shorteners (potential phishing risk)
    if (_isUrlShortener(lowerUrl)) {
      return {
        'isSafe': false, 
        'reason': 'URL shortener detected (potential risk)'
      };
    }

    // 5. Check for excessive subdomains (potential phishing)
    if (_hasExcessiveSubdomains(lowerUrl)) {
      return {
        'isSafe': false, 
        'reason': 'Suspicious domain structure'
      };
    }

    // Pass basic checks
    return {'isSafe': true, 'reason': 'Passed basic security checks'};
  }

  // Simplified method that now just calls the basic validation
  static Future<Map<String, dynamic>> checkUrlWithApi(String url) async {
    // Direct to local validation only
    return isUrlSafe(url);
  }

  // Helper to validate URL format
  static bool _isValidUrlFormat(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme.isNotEmpty && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Check for suspicious TLDs
  static bool _hasSuspiciousTld(String url) {
    return _suspiciousTlds.any((tld) => url.endsWith(tld));
  }

  // Check if URL is from a known shortener service
  static bool _isUrlShortener(String url) {
    // Extract domain from URL
    Uri? uri;
    try {
      uri = Uri.parse(url);
    } catch (e) {
      return false;
    }
    
    final host = uri.host;
    return _urlShorteners.any((shortener) => host == shortener);
  }

  // Check for excessive subdomains (potential phishing technique)
  static bool _hasExcessiveSubdomains(String url) {
    try {
      final uri = Uri.parse(url);
      final parts = uri.host.split('.');
      return parts.length > 3;  // More than 3 parts might be suspicious
    } catch (e) {
      return false;
    }
  }
} 