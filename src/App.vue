<script setup lang="ts">
import { RouterView } from 'vue-router'
</script>

<template>
  <RouterView v-slot="{ Component }">
    <transition name="page" mode="out-in" appear>
      <component :is="Component" />
    </transition>
  </RouterView>
</template>

<style>
.page-enter-active { transition: opacity 0.35s var(--ease-out-soft), transform 0.35s var(--ease-out-soft); }
.page-leave-active { transition: opacity 0.2s ease; }
.page-enter-from { opacity: 0; transform: translateY(8px); }
.page-leave-to { opacity: 0; }
@media (prefers-reduced-motion: reduce) {
  .page-enter-active, .page-leave-active { transition: none !important; }
  .page-enter-from { transform: none !important; }
}
</style>