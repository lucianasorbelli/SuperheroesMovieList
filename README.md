# 🎬 SuperheroesMovieList

**SuperheroesMovieList** is an iOS app built with **SwiftUI** and **Combine**, following a clean **MVVM architecture** with a **state machine** for robust and scalable UI management.  

The project is designed with:
- Views are fully separated from business logic.  
- Networking is powered by a **custom layer** (no third-party dependencies).  

---

##  Features
-  **Search**: Quickly find movies by title.  
-  **Sort**: Toggle ascending/descending by release year.  
-  **Infinite Scrolling**: Load more content as you browse.  
-  **State Machine**: Seamless transitions between loading, success, and error.  
-  **Detail View**: Bottom sheet presentation with `.presentationDetents`.  
-  **Accessibility Support**: Dynamic type, VoiceOver labels, and semantic UI.  
-  **Custom Networking Layer**: Built from scratch with `URLSession` and generics for decoding.  

---

##  Requirements
- macOS 14.0+  
- Xcode 15+  
- iOS 16+  
- Swift 5.9+  

---

##  Installation
Clone the repository:

```bash
git clone https://github.com/your-username/SuperheroesMovieList.git
cd SuperheroesMovieList
open SuperheroesMovieList.xcodeproj
