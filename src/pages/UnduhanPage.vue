<script setup lang="ts">
import SectionHeading from '@/components/ui/SectionHeading.vue'
import Badge from '@/components/ui/Badge.vue'
import { ref, onMounted, computed } from 'vue'
import { supabase, storageUrl } from '@/lib/supabase'

interface Doc {
  id: string
  title: string
  category: string
  file_url: string
  file_type?: string
  file_size?: number
  published_at?: string | null
}

const docs = ref<Doc[]>([])
const loading = ref(true)
const search = ref('')
const cat = ref('semua')
const error = ref('')

onMounted(async () => {
  try {
    const { data } = await supabase
      .from('documents')
      .select('id,title,category,file_url,file_type,file_size,published_at')
      .order('published_at', { ascending: false })
    docs.value = (data ?? []) as Doc[]
  } catch (e) {
    error.value = 'Gagal memuat dokumen.'
  } finally {
    loading.value = false
  }
})

const categories = ['semua', 'regulasi', 'formulir', 'pedoman', 'kode-etik', 'lainnya']

const filtered = computed(() => {
  return docs.value.filter((d) => {
    const okCat = cat.value === 'semua' || d.category === cat.value
    const q = search.value.trim().toLowerCase()
    const okSearch = !q || d.title.toLowerCase().includes(q)
    return okCat && okSearch
  })
})
</script>

<template>
  <div class="brand-gradient-bg">
    <section class="mx-auto max-w-4xl px-4 py-16 md:px-6">
      <h1 class="font-display text-3xl font-bold text-ink md:text-4xl">Unduhan</h1>
      <p class="mt-3 text-sm text-ink-soft md:text-base">
        Dokumen dan regulasi resmi terkait pencegahan serta penanganan kekerasan di lingkungan kampus.
      </p>
    </section>

    <section class="mx-auto max-w-4xl px-4 pb-16 md:px-6">
      <SectionHeading heading="Daftar Dokumen" />

      <div class="mb-4 grid gap-3 md:grid-cols-2">
        <input
          v-model="search"
          name="search"
          type="search"
          placeholder="Cari judul dokumen…"
          class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink focus:outline-2 focus:outline-link"
        />
        <select
          v-model="cat"
          name="category"
          class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink"
        >
          <option v-for="c in categories" :key="c" :value="c">
            {{ c === 'semua' ? 'Semua kategori' : c }}
          </option>
        </select>
      </div>

      <p v-if="error" class="mb-4 text-sm text-danger" role="alert">{{ error }}</p>
      <p v-if="loading" class="py-10 text-center text-muted">Memuat…</p>

      <div v-else-if="filtered.length" class="overflow-hidden rounded-2xl ring-1 ring-border">
        <table class="w-full text-left text-sm">
          <thead class="bg-surface text-xs uppercase tracking-wide text-muted">
            <tr>
              <th class="px-4 py-3">Judul</th>
              <th class="hidden px-4 py-3 md:table-cell">Kategori</th>
              <th class="px-4 py-3">Berkas</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-border bg-white/90">
            <tr v-for="d in filtered" :key="d.id" class="hover:bg-brand-blue-soft/60">
              <td class="px-4 py-3 text-ink">{{ d.title }}</td>
              <td class="hidden px-4 py-3 md:table-cell">
                <Badge tone="blue">{{ d.category }}</Badge>
              </td>
              <td class="px-4 py-3">
                <a :href="storageUrl(d.file_url) ?? '#'" target="_blank" rel="noopener" class="font-medium text-link hover:underline">
                  Unduh{{ d.file_size ? ` · ${Math.round(d.file_size / 1024)} KB` : '' }}
                </a>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-else class="glass-gradient rounded-2xl p-6 text-center text-sm text-ink-soft">
        Belum ada dokumen yang tersedia pada kategori ini.
      </div>
    </section>
  </div>
</template>