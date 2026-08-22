<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { RouterLink } from 'vue-router'
import SectionHeading from '@/components/ui/SectionHeading.vue'
import Badge from '@/components/ui/Badge.vue'
import { supabase, storageUrl } from '@/lib/supabase'

interface Post {
  id: string
  title: string
  excerpt?: string | null
  category?: string | null
  cover_url?: string | null
  published_at?: string | null
}

const posts = ref<Post[]>([])
const loading = ref(true)
const error = ref('')

onMounted(async () => {
  try {
    const { data } = await supabase
      .from('posts')
      .select('id,title,excerpt,category,cover_url,published_at')
      .eq('status', 'published')
      .order('published_at', { ascending: false })
    posts.value = (data ?? []) as Post[]
  } catch (e) {
    error.value = 'Gagal memuat berita.'
  } finally {
    loading.value = false
  }
})

const visible = computed(() => posts.value.slice(0, 12))
</script>

<template>
  <div class="brand-gradient-bg">
    <section class="mx-auto max-w-4xl px-4 py-16 md:px-6">
      <h1 class="font-display text-3xl font-bold text-ink md:text-4xl">Berita</h1>
      <p class="mt-3 text-sm text-ink-soft md:text-base">
        Informasi kegiatan dan publikasi Satgas PPKPT Universitas Adzkia.
      </p>
    </section>

    <section class="mx-auto max-w-4xl px-4 pb-16 md:px-6">
      <SectionHeading heading="Terbaru" />
      <p v-if="error" class="mb-4 text-sm text-danger" role="alert">{{ error }}</p>
      <p v-if="loading" class="py-10 text-center text-muted">Memuat…</p>

      <div v-if="!loading && visible.length" class="grid gap-5 sm:grid-cols-2">
        <RouterLink
          v-for="(p, i) in visible"
          :key="p.id"
          :to="`/berita/${p.id}`"
          class="glass-gradient group overflow-hidden rounded-2xl transition-transform duration-150 hover:scale-102"
          v-motion
          :initial="{ opacity: 0, y: 16 }"
          :enter="{ opacity: 1, y: 0, transition: { duration: 400, delay: i * 80 } }"
        >
          <div class="aspect-video overflow-hidden">
            <img
              v-if="p.cover_url"
              :src="storageUrl(p.cover_url) ?? undefined"
              :alt="p.title"
              loading="lazy"
              class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
            />
            <div v-else class="h-full w-full bg-gradient-to-br from-brand-blue to-brand-blue-soft" />
          </div>
          <div class="p-5">
            <div class="flex items-center gap-2">
              <Badge v-if="p.category" tone="blue">{{ p.category }}</Badge>
              <span v-if="p.published_at" class="text-xs text-muted">
                {{ new Date(p.published_at).toLocaleDateString('id-ID') }}
              </span>
            </div>
            <p class="mt-2 font-display font-semibold text-ink">{{ p.title }}</p>
            <p v-if="p.excerpt" class="mt-1 line-clamp-2 text-sm text-ink-soft">{{ p.excerpt }}</p>
          </div>
        </RouterLink>
      </div>

      <div v-else-if="!loading" class="glass-gradient rounded-2xl p-6 text-center text-sm text-ink-soft">
        Belum ada berita yang dipublikasikan.
      </div>
    </section>
  </div>
</template>