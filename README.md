# Movo 👾

Movo is a gamified sport-health application designed to make fitness fun, engaging, and social. Built with modern SwiftUI, Movo turns your daily activity and health metrics into a dynamic, evolving virtual companion. 

## Features 🚀

- **Gamified Health & Fitness**: Your daily activities (steps, workouts, sleep, hydration) directly influence the growth and mood of your Movo character.
- **Dynamic Character Evolution**: Start with a simple egg and evolve your character through 5 distinct stages based on your fitness journey.
- **Mood Engine**: Your Movo's facial expressions and behavior change dynamically (Happy, Fired Up, Annoyed, Wrecked, Sulking) depending on your recent activity levels and consistency.
- **Crew Feed**: A social feed where you can see your friends' workouts, view their Movo characters (with their current outfits and moods), and drop emoji reactions on their posts.
- **Wardrobe System**: Unlock and equip different accessories (headbands, capes, crowns, running shoes) as you level up and reach new milestones.
- **Live Workout Sessions**: Real-time workout tracking with a specialized UI to keep you in the zone.
- **Advanced Activity Tracking (Coming Soon)**: Detailed tracking of running/swimming routes via GPS, continuous heart rate monitoring, and comprehensive session analytics.
- **Health Dashboard**: A clean, glanceable grid summarizing your daily stats like resting heart rate, sleep duration, screen time, and water intake.

## Technologies 🛠️

- **Platform**: iOS 17.0+
- **Framework**: SwiftUI
- **Architecture**: Centralized `AppStore` (State Management)
- **Design**: Custom declarative shapes for procedural character rigging, allowing seamless animations and states without relying on static image assets.

## Getting Started 🏁

### Prerequisites
- macOS running Xcode 15 or later.
- Target device or simulator running iOS 17.0 or later.

### Installation & Running
1. Clone or download the repository.
2. Open `Movo.xcodeproj` in Xcode.
3. Select your preferred iOS Simulator or physical device from the target drop-down menu.
4. Hit `Cmd + R` or click the **Play** button to build and run the application.

## Project Structure 📁

- `App/`: Contains the main entry point (`MovoApp.swift`), global state (`AppStore`), and `RootView` (tab navigation).
- `Models/`: Core data structures (Character, Mood, Stage, Exercise, FeedPost).
- `Views/`:
  - `Character/`: Home screen and procedural character shape rendering.
  - `Dashboard/`: Health metrics and daily stats.
  - `Feed/`: Social crew feed and reaction components.
  - `Workout/`: Live session tracking and post-workout recaps.
  - `Wardrobe/`: Accessory selection and previews.
  - `Shared/`: Reusable UI components (RoundedCards, Banners, Buttons, Theme definitions).

## Design System 🎨

Movo uses a bespoke design system defined in `Theme.swift` and `Components.swift`. It features a dark-themed canvas (`movoCanvas`), vibrant accent colors (`movoAmber`, `movoLime`, `movoBlue`), and heavily utilizes glassmorphism, soft gradients, and custom spring animations to make the UI feel alive.
