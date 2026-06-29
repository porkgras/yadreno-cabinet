import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './hooks/useAuth'
import { Layout } from './components/Layout'
import { DashboardPage } from './pages/DashboardPage'
import { KeysPage } from './pages/KeysPage'
import { PurchasePage } from './pages/PurchasePage'
import { ReferralPage } from './pages/ReferralPage'
import { LoginPage } from './pages/LoginPage'
import { KeyDetailPage } from './pages/KeyDetailPage'

function App() {
  const { isAuthenticated, isLoading } = useAuth()

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600 dark:text-gray-400">Загрузка...</p>
        </div>
      </div>
    )
  }

  return (
    <Router>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/" element={
          isAuthenticated ? <Layout /> : <Navigate to="/login" replace />
        }>
          <Route index element={<DashboardPage />} />
          <Route path="keys" element={<KeysPage />} />
          <Route path="keys/:id" element={<KeyDetailPage />} />
          <Route path="purchase" element={<PurchasePage />} />
          <Route path="referral" element={<ReferralPage />} />
        </Route>
      </Routes>
    </Router>
  )
}

export default App
