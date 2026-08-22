import { createRouter, createWebHistory } from 'vue-router'
import PublicLayout from '@/layouts/PublicLayout.vue'
import AdminLayout from '@/layouts/AdminLayout.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      component: PublicLayout,
      children: [
        { path: '', name: 'home', component: () => import('@/pages/HomePage.vue') },
        { path: 'tentang', name: 'tentang', component: () => import('@/pages/TentangPage.vue') },
        { path: 'alur', name: 'alur', component: () => import('@/pages/AlurPage.vue') },
        { path: 'unduhan', name: 'unduhan', component: () => import('@/pages/UnduhanPage.vue') },
        { path: 'berita', name: 'berita', component: () => import('@/pages/BeritaPage.vue') },
        { path: 'berita/:id', name: 'berita-detail', component: () => import('@/pages/BeritaDetailPage.vue') },
        { path: 'kontak', name: 'kontak', component: () => import('@/pages/KontakPage.vue') },
        { path: 'aduan', name: 'aduan', component: () => import('@/pages/AduanPage.vue') },
      ],
    },
    {
      path: '/admin/login',
      name: 'admin-login',
      component: () => import('@/pages/admin/LoginPage.vue'),
    },
    {
      path: '/admin',
      component: AdminLayout,
      meta: { requiresAuth: true, requiresStaff: true },
      children: [
        { path: '', redirect: { name: 'admin-dashboard' } },
        { path: 'dashboard', name: 'admin-dashboard', component: () => import('@/pages/admin/DashboardPage.vue') },
        { path: 'documents', name: 'admin-documents', component: () => import('@/pages/admin/DocumentsPage.vue') },
        { path: 'posts', name: 'admin-posts', component: () => import('@/pages/admin/PostsPage.vue') },
        { path: 'tickets', name: 'admin-tickets', component: () => import('@/pages/admin/TicketsPage.vue') },
        { path: 'satgas', name: 'admin-satgas', component: () => import('@/pages/admin/SatgasPage.vue') },
        { path: 'messages', name: 'admin-messages', component: () => import('@/pages/admin/MessagesPage.vue') },
        { path: 'settings', name: 'admin-settings', component: () => import('@/pages/admin/SettingsPage.vue') },
        { path: 'users', name: 'admin-users', component: () => import('@/pages/admin/UsersPage.vue') },
        { path: 'logs', name: 'admin-logs', component: () => import('@/pages/admin/ActivityLogPage.vue') },
      ],
    },
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
})

router.beforeEach(async (to) => {
  if (to.meta.requiresAuth) {
    const { getSession, getProfile } = await import('@/composables/useAuth')
    const session = await getSession()
    if (!session) return { name: 'admin-login' }
    const profile = await getProfile()
    if (to.meta.requiresStaff && profile && !['editor', 'admin', 'superadmin'].includes(profile.role)) {
      return { name: 'home' }
    }
  }
})

export default router