cl import from react {React}
cl import from 'react-dom/client' {createRoot}
cl import from .App {App}

cl  {
    with entry {
        let root = createRoot(document.getElementById('root'));
        root.render(<App />);
    }

}