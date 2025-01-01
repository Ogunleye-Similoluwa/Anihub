# AniHub - Manga & Anime Reader/Viewer

<p align="center">
  <img src="assets/logo.png" alt="AniHub Logo" width="200"/>
</p>

AniHub is a feature-rich Flutter application that provides a seamless experience for reading manga and watching anime. Built with modern architecture patterns and best practices, it offers a robust platform for anime and manga enthusiasts.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

## 📱 Features

### 🎯 Core Features

#### Manga Reader
- **Browse & Discovery**
  - Popular manga listing with infinite scroll
  - Genre-based filtering and sorting
  - Advanced search functionality with real-time results
  - Trending and new releases sections

- **Reading Experience**
  - High-quality image rendering
  - Multiple reading modes (Vertical scroll, Page-by-page)
  - Zoom and pan capabilities
  - Chapter progress tracking
  - Offline reading support
  - Custom reading controls
  - Next/Previous chapter navigation
  - Reading history

- **Manga Details**
  - Comprehensive manga information
  - Chapter listings with release dates
  - Author and publication details
  - Genre categorization
  - Rating and popularity metrics
  - Related manga recommendations

#### Anime Features
- **Streaming Capabilities**
  - HD quality video playback
  - Multiple server options
  - Continue watching functionality
  - Episode tracking

- **Content Management**
  - Favorites/Wishlist system
  - Watch history
  - Custom lists creation
  - Progress tracking

### 🎨 UI/UX Features
- Responsive design for all screen sizes
- Dark theme optimized for reading
- Gesture controls
- Custom animations and transitions
- Loading states and error handling
- Pull-to-refresh functionality
- Bottom sheet interactions
- Adaptive layouts

## 🏗️ Technical Architecture

### 📐 Design Pattern
- **Provider Pattern** for state management
- **Repository Pattern** for data handling
- **Service-based Architecture** for API integration
- **SOLID Principles** implementation

### 🔧 Core Technologies
- **Flutter & Dart**
  - Widget composition
  - Custom painters
  - Async programming
  - Stream controllers
  - Route management

- **State Management**
  - Provider for app-wide state
  - ChangeNotifier implementation
  - State persistence

- **Data Persistence**
  - Hive for local storage
  - Cached network images
  - Offline data synchronization

### 🌐 API Integration
1. **Jikan API (MyAnimeList)**
   - Manga/Anime metadata
   - Search functionality
   - Genre listings
   - Ratings and reviews

2. **Consumet API**
   - Manga chapter fetching
   - Image processing
   - Chapter navigation
   - Reading progress

3. **Firebase Services**
   - Analytics tracking
   - Crash reporting
   - Performance monitoring
   - User authentication (planned)



## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / VS Code
- Git
- Node.js (for Consumet API)



## 📈 Performance Optimization

- Image caching and compression
- Lazy loading for lists
- Memory management
- Network request optimization
- Widget rebuilding optimization

## 🔐 Security

- API key protection
- Data encryption
- Secure storage
- Input validation
- Error handling



## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



## 🗺️ Roadmap


- [ ] Offline mode
- [ ] Custom themes
- [ ] Social features
- [ ] Cross-device sync



## 🙏 Acknowledgments

- [Jikan API](https://jikan.moe/)
- [Consumet API](https://github.com/consumet/api.consumet.org)
- [Flutter Team](https://flutter.dev/)



## 📸 Screenshots

<p float="left">
  <img src="screenshots/home.png" width="200" />
  <img src="screenshots/manga-reader.png" width="200" />
  <img src="screenshots/anime-player.png" width="200" />
</p>



## 🌐 Supported Platforms

- Android 5.0+
- iOS 11.0+
- Web (beta)

## 🔄 Version History

### v1.0.0 (Current)
- Initial release
- Basic manga reading
- Anime streaming

### v1.1.0 (Planned)
- User accounts
- Offline mode
- Performance improvements
