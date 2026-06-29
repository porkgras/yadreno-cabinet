import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { 
  Key, 
  CheckCircle, 
  XCircle, 
  AlertCircle,
  Clock,
  ExternalLink
} from 'lucide-react'
import api from '../services/api'
import { formatDistanceToNow } from 'date-fns'
import { ru } from 'date-fns/locale'

interface KeyData {
  id: number
  name: string
  server: string
  protocol: string
  status: string
  traffic_used: number
  traffic_limit: number
  traffic_percent: number
  expire_date: string
  days_left: number
  config_url: string
}

export function KeysPage() {
  const { data, isLoading } = useQuery<{ keys: KeyData[] }>({
    queryKey: ['keys'],
    queryFn: async () => {
      const response = await api.get('/users/me/keys')
      return response.data
    }
  })

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  const keys = data?.keys || []

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'text-green-600 dark:text-green-400'
      case 'expired': return 'text-red-600 dark:text-red-400'
      case 'blocked': return 'text-yellow-600 dark:text-yellow-400'
      default: return 'text-gray-600 dark:text-gray-400'
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'active': return <CheckCircle className="h-5 w-5" />
      case 'expired': return <XCircle className="h-5 w-5" />
      case 'blocked': return <AlertCircle className="h-5 w-5" />
      default: return <Clock className="h-5 w-5" />
    }
  }

  const getStatusText = (status: string) => {
    switch (status) {
      case 'active': return 'Активен'
      case 'expired': return 'Истек'
      case 'blocked': return 'Заблокирован'
      default: return 'Неизвестно'
    }
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
          Мои ключи
        </h1>
        <Link to="/purchase" className="btn-primary">
          Купить новый
        </Link>
      </div>

      {keys.length === 0 ? (
        <div className="card p-12 text-center">
          <Key className="h-16 w-16 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
            У вас пока нет ключей
          </h3>
          <p className="text-gray-600 dark:text-gray-400 mb-4">
            Приобретите VPN-ключ, чтобы начать пользоваться сервисом
          </p>
          <Link to="/purchase" className="btn-primary inline-block">
            Купить VPN
          </Link>
        </div>
      ) : (
        <div className="grid gap-4 md:grid-cols-2">
          {keys.map((key) => (
            <Link key={key.id} to={`/keys/${key.id}`}>
              <div className="card p-6 hover:shadow-lg transition-all hover:scale-[1.02]">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                      {key.name}
                    </h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      {key.server} • {key.protocol}
                    </p>
                  </div>
                  <div className={`flex items-center ${getStatusColor(key.status)}`}>
                    {getStatusIcon(key.status)}
                    <span className="ml-1 text-sm font-medium">
                      {getStatusText(key.status)}
                    </span>
                  </div>
                </div>

                <div className="mt-4 space-y-2">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-gray-600 dark:text-gray-400">Трафик</span>
                    <span className="text-gray-900 dark:text-white font-medium">
                      {key.traffic_used.toFixed(1)} / {key.traffic_limit === 0 ? '∞' : key.traffic_limit.toFixed(0)} GB
                    </span>
                  </div>
                  <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                    <div 
                      className="bg-primary-600 rounded-full h-2 transition-all"
                      style={{ width: `${Math.min(key.traffic_percent, 100)}%` }}
                    />
                  </div>
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-gray-600 dark:text-gray-400">Осталось дней</span>
                    <span className={`font-medium ${
                      key.days_left <= 3 ? 'text-red-600 dark:text-red-400' : 
                      key.days_left <= 7 ? 'text-yellow-600 dark:text-yellow-400' : 
                      'text-green-600 dark:text-green-400'
                    }`}>
                      {key.days_left} дн.
                    </span>
                  </div>
                </div>

                {key.config_url && (
                  <div className="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700">
                    <button 
                      className="text-sm text-primary-600 dark:text-primary-400 hover:underline flex items-center"
                      onClick={(e) => {
                        e.preventDefault()
                        window.open(key.config_url, '_blank')
                      }}
                    >
                      <ExternalLink className="h-4 w-4 mr-1" />
                      Получить конфиг
                    </button>
                  </div>
                )}
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  )
}
