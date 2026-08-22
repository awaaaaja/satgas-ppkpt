<script setup lang="ts">
import { RouterLink } from 'vue-router'

defineProps<{
  to?: string
  href?: string
  variant?: 'primary' | 'outline' | 'glass' | 'danger'
  type?: 'button' | 'submit'
  disabled?: boolean
}>()
</script>

<template>
  <component
    :is="to ? RouterLink : href ? 'a' : 'button'"
    v-bind="to ? { to } : href ? { href, target: '_blank', rel: 'noopener' } : { type, disabled }"
    class="inline-flex items-center justify-center gap-2 rounded-md px-5 py-2.5 text-sm font-medium transition-transform duration-150 active:scale-98 disabled:opacity-60"
    :class="{
      'bg-brand-blue text-white hover:scale-102': variant === 'primary' || !variant,
      'ring-1 ring-link text-link hover:bg-brand-blue-soft': variant === 'outline',
      'glass text-ink-soft': variant === 'glass',
      'bg-brand-red text-white hover:scale-102': variant === 'danger',
    }"
  >
    <slot />
  </component>
</template>