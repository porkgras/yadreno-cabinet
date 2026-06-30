import axios from 'axios'
import toast from 'react-hot-toast'

// Используем переменную окружения или значение по умолчанию
const API_URL = '/api'

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('access_token')
      window.location.href = '/login'
      toast.error('Сессия истекла, войдите заново')
    }
    return Promise.reject(error)
  }
)

export default api
