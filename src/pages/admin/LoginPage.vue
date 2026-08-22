<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { signIn } from '@/composables/useAuth'

const router = useRouter()
const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

async function submit() {
  error.value = ''
  if (!email.value.trim() || !password.value) {
    error.value = 'Email dan kata sandi wajib diisi.'
    return
  }
  loading.value = true
  try {
    await signIn(email.value.trim(), password.value)
    router.push({ name: 'admin-dashboard' })
  } catch (e) {
    error.value = 'Email atau kata sandi salah.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <main class="brand-gradient-bg flex min-h-dvh items-center justify-center px-4 py-10">
    <div v-motion :initial="{ opacity: 0, y: 16 }" :enter="{ opacity: 1, y: 0, transition: { duration: 500 } }" class="w-full max-w-sm">
      <RouterLink to="/" class="mb-8 block text-sm font-medium text-link hover:underline">← Beranda</RouterLink>

      <h1 class="font-display text-2xl font-bold text-ink">Login Admin</h1>
      <p class="mt-1 text-sm text-ink-soft">Masuk untuk mengelola tiket aduan.</p>

      <form @submit.prevent="submit" class="glass-gradient mt-6 grid gap-4 rounded-2xl p-6">
      <label class="grid gap-1">
        <span class="text-sm font-medium text-ink">Email</span>
        <input
          v-model.trim="email"
          name="email"
          type="email"
          required
          class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink focus:outline-2 focus:outline-link"
        />
      </label>
      <label class="grid gap-1">
        <span class="text-sm font-medium text-ink">Kata sandi</span>
        <input
          v-model="password"
          name="password"
          type="password"
          required
          class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink focus:outline-2 focus:outline-link"
        />
      </label>

      <p v-if="error" class="text-sm text-danger" role="alert">{{ error }}</p>

      <button
        type="submit"
        :disabled="loading"
        class="rounded-md bg-brand-blue px-5 py-2.5 font-medium text-white transition-transform active:scale-98 disabled:opacity-60"
      >
        {{ loading ? 'Masuk…' : 'Masuk' }}
      </button>
    </form>
    </div>
  </main>
</template>