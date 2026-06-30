import axios from 'axios'

const API_URL = '/api'

export const authService = {
  async loginWithTelegram(data: any) {
    const response = await axios.post(`${API_URL}/auth/telegram`, data)
    if (response.data.access_token) {
      localStorage.setItem('access_token', response.data.access_token)
    }
    return response.data
  },

  async verifyToken(token: string) {
    try {
      await axios.get(`${API_URL}/auth/verify`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      return true
    } catch {
      localStorage.removeItem('access_token')
      return false
    }
  },

  logout() {
    localStorage.removeItem('access_token')
    window.location.href = '/login'
  }
}
