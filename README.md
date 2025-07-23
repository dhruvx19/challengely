# Challengely – Personalized Daily Challenges App

Challengely is a beautifully crafted Flutter app that delivers personalized daily challenges tailored to users’ interests and difficulty preferences. Designed with smooth animations, delightful interactions, and a robust chat-based assistant, this app creates a motivating and engaging daily routine.

---

## Features

### Onboarding & Profile Setup
- Multi-step animated onboarding (3–10 screens)
- Interest selection (fitness, creativity, mindfulness, social, learning)
- Difficulty level selector (easy/medium/hard)
- Smooth page transitions and input validations
- Reusable animated components and skip option with defaults
- Preferences stored locally

### Daily Challenge Experience
- One unique challenge per day
- Animated card reveal for today's challenge
- Challenge info: title, description, estimated time, difficulty
- “Accept Challenge” button with micro-interaction
- Timer tracking + completion celebration animation (confetti)
- Pull-to-refresh (rotate among 3 preset challenges)
- Shareable challenge image (Instagram, WhatsApp, etc.)

### AI-Inspired Challenge Chat Assistant
- Chat-based motivation, hints, and reflection
- Expandable message input with 500 character limit
- Animated typing indicators with hardcoded streaming delay
- Smart, context-aware hardcoded responses
- Quick reply chips based on challenge state
- Scroll auto-management and long message handling
- Persist chat history per day

---

## Folder Structure

```

lib/
├── controllers/            # All Provider-based logic
│   ├── challenge\_controller.dart
│   ├── chat\_controller.dart
│   └── onboarding\_controller.dart
├── models/                 # Data classes: Challenge, UserPrefs, etc.
├── screens/                # UI screens (onboarding, home, chat)
├── services/               # SharedPreferences, local storage utilities
├── utils/                  # AppColors, Dimensions, enums, constants
├── widgets/                # Reusable UI components
└── main.dart               # Entry point

````

---

## State Management

We use **Provider** for clean, reactive, and maintainable state management.

| Controller              | Role                                                                 |
|-------------------------|----------------------------------------------------------------------|
| `OnboardingController`  | Manages onboarding progress, stores preferences                     |
| `ChallengeController`   | Filters challenges, tracks completion, refreshes daily challenge     |
| `ChatController`        | Handles message history, input validation, response matching         |

**Why Provider?**
- Lightweight and widely supported
- Great for local state with no backend dependencies
- Easy testing, modular design, and clear rebuild control

---

## Edge Case Handling – Fully Implemented

All critical edge cases across general, challenge, and chat flows have been addressed:

| Category      | Edge Case                                  
|---------------|---------------------------------------------
| General       | No challenges available                     
|               | Very long challenge descriptions            
|               | Button debounce (300ms)                     
| Chat          | 500 character message limit                 
|               | Empty message blocked                       
|               | Rate limiting (3 messages / 15 seconds)     
|               | Duplicate message prevention (5s)           
|               | Keyboard overlap and scroll                 
|               | App background/foreground recovery         
|               | Response variation to avoid repetition     
|               | Fallback for unrecognized inputs            

🧪 **Additional Implementations**
- Smart truncation for long content
- Pull-to-refresh for rotating challenges
- Celebration animations on challenge completion
- Dynamic message input height with color-coded counter
- Auto-scroll on input focus & message sent
- Reusable animated button and filter components

---

## Architecture Overview

The app follows **MVU (Model-View-Update)** inspired principles for clarity:

```plaintext
UI Layer (screens/, widgets/)
   ↓
State Controllers (controllers/)
   ↓
Model/Data Layer (models/)
   ↓
Storage/Service Layer (services/, SharedPreferences)
````

###  High-Level Architecture Diagram


```
                +-----------------------------+
                |      Onboarding Screen      |
                +-------------+---------------+
                              ↓
           +------------------+-------------------+
           |   OnboardingController (Provider)     |
           +------------------+-------------------+
                              ↓
                +-----------------------------+
                |     SharedPreferences       |
                +-----------------------------+

                +-----------------------------+
                |     Challenge Screen        |
                +-------------+---------------+
                              ↓
         +--------------------+--------------------+
         |  ChallengeController (Provider)         |
         +--------------------+--------------------+
                              ↓
             +-----------------------------+
             |  Filtered List of Challenges |
             +-----------------------------+

                +-----------------------------+
                |         Chat Screen         |
                +-------------+---------------+
                              ↓
           +------------------+-------------------+
           |     ChatController (Provider)        |
           +------------------+-------------------+
                              ↓
            +------------------------------+
            |   Local chat history cache   |
            +------------------------------+
```

---

## Setup Instructions

### Prerequisites

* Flutter 3.x
* Dart >= 2.19.0
* Android Studio / Xcode / VS Code
* Device or emulator

### Install dependencies

```bash
flutter pub get
```

### ▶️ Run the app

```bash
flutter run
```

> Make sure to clear SharedPreferences or call "Reset App" from profile menu for fresh onboarding.

---

## Test Instructions

1. Launch the app — go through animated onboarding
2. Accept today’s challenge — observe transition and timer
3. Open chat — test inputs, quick replies, reflection
4. Try edge cases:

   * Long message (500+ chars)
   * Empty message
   * Rapid message taps
   * Duplicate message
   * Background the app and return
5. Try “pull-to-refresh” after midnight (always fetches new challenge)

---

## Performance Optimizations

* 60fps across screens and animations
* Button debounce: 300ms
* Efficient ListViews and Chat rendering
* Chat rate-limit & message deduplication
* Minimal rebuilds using `Selector`, `Consumer`
* Shared animation components reused throughout app

---

## Chat Design & Behavior

| Feature                  | Implementation                                                           |
| ------------------------ | ------------------------------------------------------------------------ |
| Typing Indicator         | Bouncing dots with 1–3s random delay                                     |
| Input Expansion          | Grows smoothly up to 5 lines                                             |
| Character Limit Handling | Counter changes color (green → yellow → red) at thresholds               |
| Quick Reply Chips        | Contextual to current challenge state                                    |
| Hardcoded Responses      | Keyword detection, context-aware, varied responses to prevent repetition |
| Message History          | Persisted locally per challenge/day                                      |
| Fallbacks                | If message unrecognized → default motivational response shown            |

---

## App Reset

To reset user profile and preferences:

1. Tap on Profile icon (top right)
2. Select **“Start Over”**
3. Confirm reset → App returns to onboarding

---

## Tech Stack

* **Flutter 3.x**
* **Dart**
* **Provider** (state management)
* **SharedPreferences** (local storage)
* **flutter\_animate** (animations)
* **confetti** (celebration animation)
* **flutter\_svg, google\_fonts** (custom fonts/icons)

---

## Author & Contact

**Created by:** *Your Name*
📫 Email: [Dhruv Balchandani](mailto:dhruvbalchandani1@gmail.com)
🌐 [LinkedIn](https://linkedin.com/in/dhruvbalchandani) | [GitHub](https://github.com/dhruvx19)

---

## Final Notes

* All features are fully functional offline
* Chat system mimics real AI responsiveness and context
* Every UX detail — from animation to scroll handling — is optimized
* The app is designed with scalability and modularity in mind

