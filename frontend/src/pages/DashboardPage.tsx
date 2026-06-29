import { useQuery } from '@tanstack/react-query'
import { 
  Key, 
  Users, 
  CreditCard, 
  Clock,
  Activity,
  TrendingUp
} from 'lucide-react'
import api from '../services/api'
import { formatDistanceToNow } from 'date-fns'
import { ru } from 'date-fns/locale'

interface UserStats {
  id: number
  telegram_id: string
  username: string
  full_name: string
  balance: number
  keys_count: number
  active_keys: number
  referrals_count: number
  created_at: string
}

export function DashboardPage() {
  const { data: user, isLoading } = useQuery<UserStats>({
    queryKey: ['user'],
    queryFn: async () => {
      const response = await api.get('/users/me')
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

  const stats = [
    {
      name: 'Активные ключи',
      value: user?.active_keys || 0,
      icon: Key,
      color: 'text-blue-600',
      bg: 'bg-blue-50 dark:bg-blue-900/20'
    },
    {
      name: 'Рефералов',
      value: user?.referrals_count || 0,
      icon: Users,
      color: 'text-green-600',
      bg: 'bg-green-50 dark:bg-green-900/20'
    },
    {
      name: 'Баланс',
      value: `${user?.balance || 0} ⭐`,
      icon: CreditCard,
      color: 'text-purple-600',
      bg: 'bg-purple-50 dark:bg-purple-900/20'
    },
    {
      name: 'Всего ключей',
      value: user?.keys_count || 0,
      icon: Activity,
      color: 'text-orange-600',
      bg: 'bg-orange-50 dark:bg-orange-900/20'
    }
  ]

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
            Добро пожаловать, {user?.full_name || user?.username || 'Пользователь'}!
          </h1>
          <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
            Участник с {formatDistanceToNow(new Date(user?.created_at || ''), { 
              addSuffix: true, 
              locale: ru 
            })}
          </p>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => {
          const Icon = stat.icon
          return (
            <div key={stat.name} className="card p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600 dark:text-gray-400">
                    {stat.name}
                  </p>
                  <p className="mt-2 text-2xl font-bold text-gray-900 dark:text-white">
                    {stat.value}
                  </p>
                </div>
                <div className={`p-3 rounded-full ${stat.bg}`}>
                  <Icon className={`h-6 w-6 ${stat.color}`} />
                </div>
              </div>
            </div>
          )
        })}
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <div className="card p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
              Последние действия
            </h3>
            <Clock className="h-5 w-5 text-gray-400" />
          </div>
          <div className="space-y-4">
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-600 dark:text-gray-400">Нет недавних действий</span>
            </div>
          </div>
        </div>

        <div className="card p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
              Быстрые действия
            </h3>
            <TrendingUp className="h-5 w-5 text-gray-400" />
          </div>
          <div className="space-y-3">
            <a
              href="/purchase"
              className="block w-full text-center btn-primary"
            >
              Купить VPN
            </a>
            <a
              href="/keys"
              className="block w-full text-center btn-secondary"
            >
              Мои ключи
            </a>
            <a
              href="/referral"
              className="block w-full text-center btn-secondary"
            >
              Реферальная программа
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}
