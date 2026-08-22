<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/composables/useAuth'

const { session } = useAuth()

interface Post {
  id: string
  title: string
  slug: string
  excerpt: string | null
  content: string
  cover_url: string | null
  category: string | null
  status: string
  published_at: string | null
}

const posts = ref<Post[]>([])
const loading = ref(true)
const err = ref('')
const editing = ref<Post | null>(null)
const showForm = ref(false)
const form = ref({
  title: '',
  slug: '',
  excerpt: '',
  content: '',
  category: 'Kegiatan',
  status: 'draft',
  cover: null as File | null,
})
const saving = ref(false)

const categories = ['Kegiatan', 'Pengumuman', 'Edukasi', 'Lainnya']
const statuses = ['draft', 'published']

onMounted(load)

async function load() {
  loading.value = true
  const { data } = await supabase.from('posts').select('*').order('created_at', { ascending: false })
  posts.value = (data ?? []) as Post[]
  loading.value = false
}

function slugify(s: string) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'berita'
}

function openNew() {
  showForm.value = true
  editing.value = null
  form.value = { title: '', slug: '', excerpt: '', content: '', category: 'Kegiatan', status: 'draft', cover: null }
}

function openEdit(p: Post) {
  showForm.value = true
  editing.value = p
  form.value = { title: p.title, slug: p.slug, excerpt: p.excerpt ?? '', content: p.content, category: p.category ?? 'Kegiatan', status: p.status, cover: null }
}

async function save() {
  err.value = ''
  if (!form.value.title.trim() || !form.value.slug.trim()) {
    err.value = 'Judul dan slug wajib diisi.'
    return
  }
  saving.value = true
  try {
    let cover_url: string | null = null
    if (form.value.cover) {
      const name = `${Date.now()}-${form.value.cover.name.replace(/[^a-z0-9._-]/gi, '_')}`
      const { error: ue } = await supabase.storage.from('gambar').upload(name, form.value.cover)
      if (ue) throw ue
      cover_url = `/storage/v1/object/public/gambar/${name}`
    }
    const payload = {
      title: form.value.title.trim(),
      slug: form.value.slug.trim(),
      excerpt: form.value.excerpt.trim() || '-',
      content: form.value.content.trim(),
      category: form.value.category,
      status: form.value.status,
      tags: [],
      published_at: form.value.status === 'published' ? new Date().toISOString() : null,
      ...(cover_url ? { cover_url } : {}),
    }
    if (editing.value) {
      const { error: e } = await supabase.from('posts').update(payload).eq('id', editing.value.id)
      if (e) throw e
    } else {
      const { error: e } = await supabase.from('posts').insert({ ...payload, author_id: session.value!.user.id })
      if (e) throw e
    }
    editing.value = null
    showForm.value = false
    await load()
  } catch (e) {
    err.value = (e as Error).message || 'Gagal menyimpan berita.'
  } finally {
    saving.value = false
  }
}

async function remove(p: Post) {
  if (!confirm(`Hapus berita "${p.title}"?`)) return
  const { error } = await supabase.from('posts').delete().eq('id', p.id)
  if (error) {
    err.value = String((error as { message?: string }).message ?? "Gagal menghapus.")
    return
  }
  await load()
}
</script>

<template>
  <div class="max-w-5xl">
    <div class="flex items-center justify-between gap-4">
      <div>
        <h1 class="font-display text-2xl font-bold text-ink">Berita</h1>
        <p class="mt-1 text-sm text-ink-soft">Kelola berita publik (draft/published).</p>
      </div>
      <button type="button" @click="openNew" class="rounded-md bg-brand-blue px-4 py-2 text-sm font-medium text-white hover:bg-brand-blue/90">
        + Berita Baru
      </button>
    </div>

    <p v-if="err" class="mt-4 rounded-md bg-danger/10 p-3 text-sm text-danger" role="alert">{{ err }}</p>

    <form v-if="showForm" @submit.prevent="save" class="mt-6 grid gap-4 rounded-xl bg-white p-6 ring-1 ring-border">
      <div class="grid gap-4 md:grid-cols-2">
        <label class="grid gap-1 text-sm">
          <span class="font-medium text-ink">Judul *</span>
          <input v-model="form.title" name="title" required class="rounded-md border border-border px-3 py-2 text-ink focus:outline-2 focus:outline-link" />
        </label>
        <label class="grid gap-1 text-sm">
          <span class="font-medium text-ink">Slug *</span>
          <input v-model="form.slug" name="slug" required :placeholder="slugify(form.title)" class="rounded-md border border-border px-3 py-2 text-ink focus:outline-2 focus:outline-link" />
        </label>
        <label class="grid gap-1 text-sm">
          <span class="font-medium text-ink">Kategori</span>
          <select v-model="form.category" name="category" class="rounded-md border border-border px-3 py-2 text-ink">
            <option v-for="c in categories" :key="c" :value="c">{{ c }}</option>
          </select>
        </label>
        <label class="grid gap-1 text-sm">
          <span class="font-medium text-ink">Status</span>
          <select v-model="form.status" name="status" class="rounded-md border border-border px-3 py-2 text-ink">
            <option v-for="s in statuses" :key="s" :value="s">{{ s }}</option>
          </select>
        </label>
      </div>
      <label class="grid gap-1 text-sm">
        <span class="font-medium text-ink">Ringkasan</span>
        <input v-model="form.excerpt" name="excerpt" class="rounded-md border border-border px-3 py-2 text-ink" />
      </label>
      <label class="grid gap-1 text-sm">
        <span class="font-medium text-ink">Isi berita *</span>
        <textarea v-model="form.content" name="content" required rows="8" class="rounded-md border border-border px-3 py-2 text-ink focus:outline-2 focus:outline-link"></textarea>
      </label>
      <label class="grid gap-1 text-sm">
        <span class="font-medium text-ink">{{ editing ? 'Ganti gambar sampul (kosongkan untuk tetap)' : 'Gambar sampul' }}</span>
        <input
          name="cover"
          type="file"
          accept="image/webp,image/jpeg,image/png"
          class="rounded-md border border-border px-3 py-2 text-ink file:mr-3 file:rounded-md file:border-0 file:bg-brand-blue file:px-3 file:py-1.5 file:text-sm file:text-white"
          @change="form.cover = ($event.target as HTMLInputElement).files?.[0] ?? null"
        />
      </label>
      <div class="flex gap-3">
        <button type="submit" :disabled="saving" class="rounded-md bg-brand-blue px-5 py-2 text-sm font-medium text-white disabled:opacity-60">
          {{ saving ? 'Menyimpan…' : 'Simpan' }}
        </button>
        <button
          type="button"
          @click="editing = null; showForm = false; form = { title: '', slug: '', excerpt: '', content: '', category: 'Kegiatan', status: 'draft', cover: null }"
          class="rounded-md bg-white px-5 py-2 text-sm font-medium ring-1 ring-border"
        >
          Batal
        </button>
      </div>
    </form>

    <div v-if="loading" class="mt-8 py-10 text-center text-muted">Memuat…</div>
    <div v-else class="mt-6 overflow-hidden rounded-xl bg-white ring-1 ring-border">
      <table class="w-full text-left text-sm">
        <thead class="bg-surface text-xs uppercase tracking-wide text-muted">
          <tr>
            <th class="px-4 py-3">Judul</th>
            <th class="hidden px-4 py-3 md:table-cell">Status</th>
            <th class="px-4 py-3">Aksi</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-border">
          <tr v-for="p in posts" :key="p.id" class="hover:bg-brand-blue-soft/40">
            <td class="px-4 py-3 text-ink">{{ p.title }}</td>
            <td class="hidden px-4 py-3 md:table-cell">
              <span class="rounded-full px-2 py-0.5 text-xs font-medium" :class="p.status === 'published' ? 'bg-brand-blue text-white' : 'bg-surface text-muted'">
                {{ p.status }}
              </span>
            </td>
            <td class="px-4 py-3">
              <button type="button" @click="openEdit(p)" class="font-medium text-link hover:underline">Ubah</button>
              <span class="mx-2 text-border">·</span>
              <button type="button" @click="remove(p)" class="font-medium text-danger hover:underline">Hapus</button>
            </td>
          </tr>
        </tbody>
      </table>
      <p v-if="!posts.length" class="p-6 text-center text-muted">Belum ada berita.</p>
    </div>
  </div>
</template>