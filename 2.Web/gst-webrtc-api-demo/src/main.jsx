import { createRoot } from 'react-dom/client'
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom'
import './index.css'
import App from './App.jsx'

createRoot($('root')).render(
  <Router>
    <Routes>
      <Route path='/health-check' element={<>OK</>} />
      <Route path='/' element={<App />} />
    </Routes>
  </Router>,
)
