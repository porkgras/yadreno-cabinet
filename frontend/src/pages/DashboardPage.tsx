import { useQuery } from '@tanstack/react-query'
import { Shield, Users, Key, TrendingUp, Activity, Clock } from 'lucide-react'
import api from '../services/api'

interface DashboardStats {
  total_users: number
  total_keys: number
  active_keys: number
  total_referrals: number
  today_new_users: number
  today_new_keys: number
}

export function DashboardPage() {
  const { data: stats, isLoading } = useQuery<DashboardStats>({
    queryKey: ['dashboard-stats'],
    queryFn: async () => {
      const response = await api.get('/api/stats/')
      return response.data
    }
  })

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  const cards = [
    {
      title: 'Всего пользователей',
      value: stats?.total_users || 0,
      icon: Users,
      color: 'bg-blue-500'
    },
    {
      title: 'Активные ключи',
      value: stats?.active_keys || 0,
      icon: Key,
      color: 'bg-green-500'
    },
    {
      title: 'Всего ключей',
      value: stats?.total_keys || 0,
      icon: Shield,
      color: 'bg-purple-500'
    },
    {
      title: 'Рефералов',
      value: stats?.total_referrals || 0,
      icon: TrendingUp,
      color: 'bg-orange-500'
    }
  ]

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">📊 Дашборд</h1>
        <div className="flex items-center gap-2 text-sm text-gray-500">
          <Activity className="h-4 w-4" />
          <span>Обновлено: {new Date().toLocaleTimeString()}</span>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {cards.map((card, index) => (
          <div key={index} className="bg-white rounded-xl shadow-sm p-6 hover:shadow-md transition-shadow">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-500">{card.title}</p>
                <p className="text-2xl font-bold mt-1">{card.value}</p>
              </div>
              <div className={`${card.color} p-3 rounded-lg`}>
                <card.icon className="h-6 w-6 text-white" />
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl shadow-sm p-6">
          <h3 className="font-semibold text-gray-900 mb-4">📈 Активность сегодня</h3>
          <div className="space-y-3">
            <div className="flex justify-between items-center border-b pb-2">
              <span className="text-gray-600">Новых пользователей</span>
              <span className="font-semibold text-blue-600">{stats?.today_new_users || 0}</span>
            </div>
            <div className="flex justify-between items-center border-b pb-2">
              <span className="text-gray-600">Создано ключей</span>
              <span className="font-semibold text-green-600">{stats?.today_new_keys || 0}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-600">Активных сессий</span>
              <span className="font-semibold text-purple-600">{stats?.active_keys || 0}</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm p-6">
          <h3 className="font-semibold text-gray-900 mb-4">⚡ Быстрые действия</h3>
          <div className="space-y-3">
            <button className="w-full bg-blue-50 text-blue-700 px-4 py-2 rounded-lg hover:bg-blue-100 transition-colors text-sm font-medium">
              Создать новый ключ
            </button>
            <button className="w-full bg-green-50 text-green-700 px-4 py-2 rounded-lg hover:bg-green-100 transition-colors text-sm font-medium">
              Пополнить баланс
            </button>
            <button className="w-full bg-purple-50 text-purple-700 px-4 py-2 rounded-lg hover:bg-purple-100 transition-colors text-sm font-medium">
              Пригласить друга
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
