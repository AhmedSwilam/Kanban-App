# **Kanban Mobile**
-A kanban board for tasks, where users can create, edit, and move tasks between different columns (e.g. "To Do", "In Progress", "Done").
-A history of completed tasks, including the time spent on each task and the date it was completed.
- It will be important as well to follow these non-functional requirements as well:
1. Best practices of software development such as DRY (Don't Repeat Yourself), KISS (Keep It Simple, Stupid), and SOLID (Single responsibility, Open-closed, Liskov substitution, Interface segregation, Dependency inversion) should be incorporated.
2. MVP(Minimum Viable Product) principle: This principle suggests that you should aim to create a minimum viable version of the product that can be released to users as soon as possible, and then iteratively add new features and improve the existing ones based on user feedback.
3. User-centered design: The app should be designed with the user's needs, goals, and preferences in mind. This includes making the app easy to use, visually appealing, and accessible to all users.
   Take-Home Challenge for Flutter Mobile Developer 1
4. Performance optimization: The app should be optimized for performance, including fast loading times, smooth scrolling, and minimal use of memory and battery.
5. Code readability and maintainability: The code should be easy to read and understand, and should be organized in a way that makes it easy to maintain and update.
6. Using Ci Cd to build ios and android apps to firebase distribution App.

## Getting Started

## **Application Architecture**
In Kanban Mobile, we follow the **Clean Architecture** to build it. There are different opinions about how many layers Clean Architecture should have. The architecture doesn't define exact layers but instead lays out the foundation. The idea is that you adapt the number of layers to your needs.
In Kanban Mobile, we divides it into 5 layers:
- **Presentation or Features Layer:** A layer that interacts with the UI.
- **Use cases Layer:** Sometimes called interactors. Defines actions the user can trigger.
- **Domain Layer:** Contains the business logic of the app.
- **Data Layer:** Abstract definition of all the data sources.

![clean architecture layers](https://medium.com/ruangguru/an-introduction-to-flutter-clean-architecture-ae00154001b0)

To apply the previous layers, we divided our app into 4 modules:
- **Core Module:** contains 3 packages:

    - **Data Package**: provides abstract definitions (Repository & Interfaces) for accessing data sources like a database and internet. Repository Pattern  is used in this layer. The main purpose of the Repository Pattern is to abstract away the concrete implementation of data access.

    - **Domain Package**: contains all the models and business rules of your app.

    - **Usecases Package**: converts user actions to inner layers of the application.

- **Presentation Module:** contains the user interface related code.

**Some Instructions From Uncle Bob:**
- Nothing in an inner circle can know anything at all about something in an outer circle. In particular, the name of something declared in an outer circle must not be mentioned by the code in an inner circle.

- Interface Adapters: The software in this layer is a set of adapters that convert data from the format most convenient for the use cases and entities, to the format most convenient for some external agency such as the Database or the Web. It is this layer, for example, that will wholly contain the MVC architecture of a GUI. The Presenters, Views, and Controllers all belong here.

- Important Example: consider that the use case needs to call the presenter. However, this call must not be direct because that would violate The Dependency Rule: No name in an outer circle can be mentioned by an inner circle. So we have the use case call an interface (Shown here as Use Case Output Port) in the inner circle, and have the presenter in the outer circle implement it. The same technique is used to cross all the boundaries in the architectures.

- Typically the data that crosses the boundaries is simple data structures. You can use basic structs or simple Data Transfer objects if you like. Or the data can simply be arguments in function calls. Or you can pack it into a hashmap, or construct it into an object. The important thing is that isolated, simple, data structures are passed across the boundaries. We don’t want to cheat and pass Entities or Database rows. We don’t want the data structures to have any kind of dependency that violates The Dependency Rule.

### **2. core module**
Core module contains all the code that doesn't depend on Android SDK. It will have the implementation of Data, Domain and Usecase layers.

- **Data Package**: for each model, a package is created that contains :
    - DataStore Interface.

    - Repository Interface.

    - RepositoryImpl Class.

- **Domain Package**: contains all entities files i.e. **User** & **Product**.

- **UseCase Package**: for each model, a package is created that contains all the use cases that will operate on this model i.e. **GetUserTokenUseCase**

📦 core</br>
┣
┃  ┣ 📜 Constatnts.kt</br>
┃  ┣ 📜 Di.kt</br>
┃  ┗ 📜 Error.kt</br>
┃  ┗ 📜 Network.kt</br>
┃  ┗ 📜 Util.kt</br>
┃  ┗ 📜 Widgets.kt</br>


📦 features</br>
┃ ┣ 📜 App Features.kt</br>
┃ ┃  ┣📂 Data.kt</br>
┃ ┃  ┣📂 usecases</br>
┃ ┃  ┣📂 Domain</br>
┃ ┃  ┣📂 Presentation</br>

# **Notes to run the application**
- In Order to run the app in debug mode you need to  execute the following command to generate files:
```
flutter packages pub run build_runner build --delete-conflicting-outputs

