<script setup lang="ts">
defineProps<{
  heading: string
  lead?: string
}>()
</script>

<template>
  <header class="mb-6">
    <h2 class="font-display text-2xl font-bold text-ink md:text-3xl">{{ heading }}</h2>
    <p v-if="lead" class="mt-2 max-w-2xl text-sm text-ink-soft md:text-base">{{ lead }}</p>
  </header>
</template>