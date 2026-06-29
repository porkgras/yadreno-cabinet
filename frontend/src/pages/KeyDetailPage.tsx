import { useParams, Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { 
  ArrowLeft, 
  Copy, 
  Download, 
  ExternalLink,
  Calendar,
  Server,
  Wifi,
  Shield,
  AlertTriangle
} from 'lucide-react'
import api from '../services/api'
import toast from 'react-hot-toast'

interface KeyDetail {
  id: number
  name: string
  server: string
  server_ip: string
  protocol: string
  port: number
  status: string
  traffic_used: number
  traffic_limit: number
  traffic_percent: number
  expire_date: string
  created_at: string
  days_left: number
  config_url: string
  subscription_url: string
}

export function KeyDetailPage() {
  const { id } = useParams<{ id: string }>()
  
  const { data: key, isLoading } = useQuery<KeyDetail>({
    queryKey: ['key', id],
    queryFn: async () => {
      const response = await api.get(`/users/me/keys/${id}`)
      return response.data
    },
    enabled: !!id
  })

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text)
    toast.success('Скопировано!')
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  if (!key) {
    return (
      <div className="card p-12 text-center">
        <AlertTriangle className="h-16 w-16 text-yellow-500 mx-auto mb-4" />
        <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
          Ключ не найден
        </h3>
        <Link to="/keys" className="text-primary-600 hover:underline">
          Вернуться к списку
        </Link>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <Link to="/keys" className="inline-flex items-center text-primary-600 hover:underline">
        <ArrowLeft className="h-4 w-4 mr-1" />
        Назад к списку
      </Link>

      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
          {key.name}
        </h1>
        <span className={`px-3 py-1 rounded-full text-sm font-medium ${
          key.status === 'active' 
            ? 'bg-green-100 dark:bg-green-900/20 text-green-600 dark:text-green-400'
            : 'bg-red-100 dark:bg-red-900/20 text-red-600 dark:text-red-400'
        }`}>
          {key.status === 'active' ? 'Активен' : 'Истек'}
        </span>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Информация о подключении
          </h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-600 dark:text-gray-400">Сервер</span>
              <span className="text-gray-900 dark:text-white font-medium">{key.server}</span>
            </div>
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-600 dark:text-gray-400">IP адрес</span>
              <span className="text-gray-900 dark:text-white font-medium">{key.server_ip}</span>
            </div>
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-600 dark:text-gray-400">Протокол</span>
              <span className="text-gray-900 dark:text-white font-medium">{key.protocol}</span>
            </div>
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-600 dark:text-gray-400">Порт</span>
              <span className="text-gray-900 dark:text-white font-medium">{key.port}</span>
            </div>
          </div>
        </div>

        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Статистика
          </h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-600 dark:text-gray-400">Использовано трафика</span>
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
              <span className="text-gray-600 dark:text-gray-400">Действует до</span>
              <span className="text-gray-900 dark:text-white font-medium">
                {new Date(key.expire_date).toLocaleDateString()}
              </span>
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
        </div>
      </div>

      <div className="card p-6">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Настройки подключения
        </h3>
        <div className="flex flex-wrap gap-4">
          {key.config_url && (
            <button
              onClick={() => copyToClipboard(key.config_url)}
              className="btn-secondary flex items-center"
            >
              <Copy className="h-4 w-4 mr-2" />
              Копировать конфиг
            </button>
          )}
          {key.subscription_url && (
            <button
              onClick={() => copyToClipboard(key.subscription_url)}
              className="btn-secondary flex items-center"
            >
              <Download className="h-4 w-4 mr-2" />
              Копировать подписку
            </button>
          )}
          {key.config_url && (
            <button
              onClick={() => window.open(key.config_url, '_blank')}
              className="btn-secondary flex items-center"
            >
              <ExternalLink className="h-4 w-4 mr-2" />
              Открыть конфиг
            </button>
          )}
        </div>
      </div>
    </div>
  )
}
