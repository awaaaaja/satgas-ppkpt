<script setup lang="ts">
defineProps<{
  tone?: 'blue' | 'red' | 'neutral'
}>()
</script>

<template>
  <span
    class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium"
    :class="{
      'bg-brand-blue-soft text-link': tone === 'blue' || !tone,
      'bg-brand-red-soft text-brand-red-dark': tone === 'red',
      'bg-surface text-ink-soft ring-1 ring-border': tone === 'neutral',
    }"
  >
    <slot />
  </span>
</template>