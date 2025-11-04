# Todo App - React-Style Project Structure

This is a fully modular todo application organized like a React/Next.js project, demonstrating best practices for organizing Jac code.

## 📁 Project Structure (Flat File Organization)

Since Jac currently supports single-level imports, all files are organized in a flat structure with descriptive naming:

```
todo-react-project-style/
├── app.jac                      # Main entry point with routing
├── models.jac                   # Data models (nodes & walkers)
├── hook_useTodos.jac            # Custom hook for todo operations
├── hook_useAuth.jac             # Custom hook for authentication
├── component_button.jac         # Reusable button component
├── component_input.jac          # Reusable input component
├── component_card.jac           # Container component
├── component_todoItem.jac        # Individual todo item
├── component_todoList.jac        # List of todos
├── component_todoForm.jac        # Form for adding todos
├── page_login.jac               # Login page
├── page_signup.jac             # Signup page
└── page_todos.jac              # Main todos page
```

**Naming Convention:**
- `hook_*` - Custom hooks
- `component_*` - UI components
- `page_*` - Page components
- `models.jac` - Backend models

## 🏗️ Architecture

### Backend (models.jac)
- **Nodes**: `Todo` - Data model for todos
- **Walkers**: 
  - `create_todo` - Creates new todos
  - `toggle_todo` - Toggles todo completion status
  - `delete_todo` - Deletes a todo
  - `read_todos` - Fetches all todos

### Frontend

#### Custom Hooks (`hooks/`)
- **useTodos**: Manages todo state and CRUD operations
- **useAuth**: Handles authentication (login, signup, logout)

#### UI Components (`components/`)
- **Button**: Reusable button with variants (primary, danger, secondary)
- **Input**: Controlled input component
- **Card**: Container component with card styling
- **TodoItem**: Individual todo item component
- **TodoList**: List component that renders todos
- **TodoForm**: Form component for adding new todos

#### Pages (`pages/`)
- **LoginPage**: Login form with authentication
- **SignupPage**: Signup form with validation
- **TodosPage**: Main page with todo list and management

## 🚀 Features

- ✅ Modular architecture (separate files for each concern)
- ✅ Component-based UI (reusable components)
- ✅ Custom hooks (state management patterns)
- ✅ Authentication (login/signup/logout)
- ✅ Route guards (protected routes)
- ✅ Error handling
- ✅ Loading states
- ✅ Clean separation of concerns

## 📝 Usage

1. Run the app:
   ```bash
   jac serve todo-react-project-style/app.jac
   ```

2. Navigate to the app in your browser

3. Create an account or login to start managing todos

## 🎯 React/Next.js Patterns Used

- **Component Composition**: Components receive props and compose together
- **Custom Hooks**: Reusable stateful logic (`useTodos`, `useAuth`)
- **Page Components**: Route-level components (`LoginPage`, `TodosPage`)
- **Module Organization**: Clear separation of models, hooks, components, and pages
- **Import System**: Clean imports using `cl import from` syntax

This structure makes the codebase maintainable, scalable, and easy to understand for developers familiar with React/Next.js patterns.
