<template>
  <div class="error-container" v-if="show">
    <div class="error-message">
      <div class="error-header">
        <i class="fas fa-exclamation-triangle"></i>
        <h4>{{ title }}</h4>
        <button class="close-btn" @click="$emit('close')">
          <i class="fas fa-times"></i>
        </button>
      </div>
      <div class="error-body">
        <p>{{ message }}</p>
        <div class="suggestion" v-if="suggestion">
          <strong>Suggestion:</strong> {{ suggestion }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    show: {
      type: Boolean,
      default: false
    },
    title: {
      type: String,
      default: 'Error'
    },
    message: {
      type: String,
      required: true
    },
    suggestion: {
      type: String,
      default: ''
    }
  },
  emits: ['close']
}
</script>

<style scoped>
.error-container {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 1000;
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

.error-message {
  background-color: #fff;
  border-left: 4px solid #e74c3c;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  width: 320px;
  border-radius: 4px;
  overflow: hidden;
}

.error-header {
  background-color: #fcf0f0;
  padding: 12px 15px;
  display: flex;
  align-items: center;
}

.error-header i {
  color: #e74c3c;
  font-size: 18px;
  margin-right: 10px;
}

.error-header h4 {
  margin: 0;
  font-size: 16px;
  flex: 1;
}

.close-btn {
  background: none;
  border: none;
  color: #666;
  cursor: pointer;
  font-size: 14px;
}

.error-body {
  padding: 15px;
  font-size: 14px;
}

.error-body p {
  margin: 0 0 10px 0;
}

.suggestion {
  background-color: #f8f9fa;
  padding: 10px;
  border-radius: 4px;
  font-size: 13px;
  margin-top: 10px;
}
</style>
