<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import { supabase, storageUrl } from '@/lib/supabase'

const route = useRoute()
const post = ref<{ title: string; content: string; cover_url?: string | null; category?: string | null; published_at?: string | null } | null>(null)
const loading = ref(true)

onMounted(async () => {
  try {
    const { data } = await supabase
      .from('posts')
      .select('title,content,cover_url,category,published_at')
      .eq('id', route.params.id)
      .eq('status', 'published')
      .single()
    post.value = data as typeof post.value
  } catch (e) {
    /* post tidak ditemukan atau belum published */
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="brand-gradient-bg">
    <section class="mx-auto max-w-3xl px-4 py-16 md:px-6">
      <nav class="mb-6 text-sm">
        <RouterLink to="/berita" class="font-medium text-link hover:underline">← Semua Berita</RouterLink>
      </nav>

      <p v-if="loading" class="py-10 text-center text-muted">Memuat…</p>

      <article v-else-if="post" class="glass-gradient rounded-2xl p-6 md:p-8">
        <div class="flex flex-wrap items-center gap-2 text-xs text-muted">
          <span v-if="post.category" class="rounded-full bg-brand-blue px-2 py-0.5 font-medium text-white">{{ post.category }}</span>
          <span v-if="post.published_at">{{ new Date(post.published_at).toLocaleDateString('id-ID') }}</span>
        </div>
        <h1 class="mt-3 font-display text-2xl font-bold text-ink md:text-3xl">{{ post.title }}</h1>
        <img
          v-if="post.cover_url"
          :src="storageUrl(post.cover_url) ?? undefined"
          :alt="post.title"
          class="mt-5 aspect-video w-full rounded-xl object-cover"
          loading="lazy"
        />
        <div class="mt-4 whitespace-pre-wrap text-sm leading-relaxed text-ink-soft md:text-base">
          {{ post.content }}
        </div>
      </article>

      <div v-else class="glass-gradient rounded-2xl p-6 text-center text-sm text-ink-soft">
        Berita tidak ditemukan.
      </div>
    </section>
  </div>
</template>