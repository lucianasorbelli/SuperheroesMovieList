# 🎬 SuperheroesMovieList

<img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/6d18f2ff-ffcb-4830-95a4-3a4811cd393c" />


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
```

📌 Notes
While the original challenge specified three separate buttons (sort, order, and reset),
I made a design decision to merge sort and order into a single toggle by year.
This provides a cleaner UX without losing functionality, since the user can still switch between ascending and descending order intuitively.
