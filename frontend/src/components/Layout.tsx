import { Outlet, Link, useLocation } from 'react-router-dom'
import { 
  LayoutDashboard, 
  Key, 
  ShoppingCart, 
  Users, 
  LogOut,
  Menu,
  X
} from 'lucide-react'
import { useState } from 'react'
import { authService } from '../services/auth'

const navigation = [
  { name: 'Дашборд', href: '/', icon: LayoutDashboard },
  { name: 'Мои ключи', href: '/keys', icon: Key },
  { name: 'Купить', href: '/purchase', icon: ShoppingCart },
  { name: 'Рефералы', href: '/referral', icon: Users },
]

export function Layout() {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const location = useLocation()

  const handleLogout = () => {
    authService.logout()
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Mobile sidebar */}
      <div className="lg:hidden">
        <div className="fixed inset-0 z-40 flex">
          <div className={`fixed inset-0 bg-gray-900/80 transition-opacity ${sidebarOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'}`} onClick={() => setSidebarOpen(false)} />
          <div className={`relative flex w-full max-w-xs flex-1 flex-col bg-white dark:bg-gray-800 transition-transform ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
            <div className="flex h-16 items-center justify-between px-4">
              <span className="text-xl font-bold text-primary-600">Yadreno Cabinet</span>
              <button onClick={() => setSidebarOpen(false)} className="p-2">
                <X className="h-6 w-6" />
              </button>
            </div>
            <nav className="flex-1 space-y-1 px-2 py-4">
              {navigation.map((item) => {
                const isActive = location.pathname === item.href
                return (
                  <Link
                    key={item.name}
                    to={item.href}
                    className={`flex items-center px-4 py-3 rounded-lg transition-colors ${
                      isActive
                        ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600 dark:text-primary-400'
                        : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
                    }`}
                    onClick={() => setSidebarOpen(false)}
                  >
                    <item.icon className="h-5 w-5 mr-3" />
                    {item.name}
                  </Link>
                )
              })}
            </nav>
            <div className="border-t border-gray-200 dark:border-gray-700 p-4">
              <button
                onClick={handleLogout}
                className="flex w-full items-center px-4 py-3 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors"
              >
                <LogOut className="h-5 w-5 mr-3" />
                Выйти
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Desktop sidebar */}
      <div className="hidden lg:fixed lg:inset-y-0 lg:flex lg:w-64">
        <div className="flex flex-col flex-1 bg-white dark:bg-gray-800 border-r border-gray-200 dark:border-gray-700">
          <div className="flex h-16 items-center px-6 border-b border-gray-200 dark:border-gray-700">
            <span className="text-xl font-bold text-primary-600">Yadreno Cabinet</span>
          </div>
          <nav className="flex-1 space-y-1 px-3 py-4">
            {navigation.map((item) => {
              const isActive = location.pathname === item.href
              return (
                <Link
                  key={item.name}
                  to={item.href}
                  className={`flex items-center px-4 py-3 rounded-lg transition-colors ${
                    isActive
                      ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600 dark:text-primary-400'
                      : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
                  }`}
                >
                  <item.icon className="h-5 w-5 mr-3" />
                  {item.name}
                </Link>
              )
            })}
          </nav>
          <div className="border-t border-gray-200 dark:border-gray-700 p-4">
            <button
              onClick={handleLogout}
              className="flex w-full items-center px-4 py-3 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors"
            >
              <LogOut className="h-5 w-5 mr-3" />
              Выйти
            </button>
          </div>
        </div>
      </div>

      {/* Main content */}
      <div className="lg:pl-64">
        <div className="sticky top-0 z-10 bg-white/80 dark:bg-gray-900/80 backdrop-blur-sm border-b border-gray-200 dark:border-gray-700 lg:hidden">
          <div className="flex h-16 items-center px-4">
            <button onClick={() => setSidebarOpen(true)} className="p-2">
              <Menu className="h-6 w-6" />
            </button>
            <span className="ml-4 text-lg font-semibold">Yadreno Cabinet</span>
          </div>
        </div>
        <main className="p-4 sm:p-6 lg:p-8">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
