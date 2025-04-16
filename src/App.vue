<template>
  <div id="app" class="container">
    <!-- Title area -->
    <div class="title-area">
      <h2>Convert HEIC to JPEG</h2>
      <p class="conversion-info">Fast, free, and completely private - your files never leave your device!</p>
    </div>

    <!-- Combined upload/drop area with conditional styling -->
    <div :class="{
         'drop-area': showDropZone, 
         'upload-section': !showDropZone,
         'dragover': isDragging && showDropZone
       }" 
         @dragover.prevent="showDropZone && dragOver()" 
         @dragleave.prevent="showDropZone && dragLeave()" 
         @drop.prevent="showDropZone && dropFiles($event)">
      
      <!-- Upload button (always visible) -->
      <button class="upload-button btn" @click="openFileDialog">
        <i class="fas fa-upload"></i> Upload HEIC Files
      </button>
      <input type="file" ref="fileInput" @change="filesSelected" accept="image/heic" multiple>

      <!-- Drop zone elements (only visible on desktop) -->
      <template v-if="showDropZone">
        <div class="divider">or</div>
        <p class="drop-label">Drop files here</p>
      </template>
    </div>

    <!-- Loader spinner -->
    <div v-if="isLoading" class="loader"></div>

    <!-- Convert button -->
    <button v-if="files.length > 0 && !isLoading" class="convert-button" @click="convertFiles">
      <i class="fas fa-sync-alt"></i> Convert
    </button>

    <div class="table-container" v-if="files.length > 0 && !isLoading">
      <h6>Your files</h6>
      <table class="table mt-4">
        <tbody>
          <tr v-for="(file, index) in files" :key="index">
            <td class="file-name">
              <i class="fas fa-camera-retro"></i> {{ file.name }} ({{ (file.size / 1024).toFixed(2) }} KB)
            </td>
            <td class="text-center button-cell">
              <button class="btn btn-danger btn-sm" @click="removeFile(index)">
                <i class="fas fa-times"></i>
              </button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="text-center">
        <button v-if="files.length > 0" class="clear-button btn" @click="clearFiles">
          <i class="fas fa-trash"></i> Clear
        </button>
      </div>
    </div>
    
    <!-- FAQ Section -->
    <div class="faq-section">
      <h3>Frequently Asked Questions</h3>
      <div class="faq-container">
        <div v-for="(faq, index) in faqs" :key="index" class="faq-item">
          <div class="faq-question" @click="toggleFaq(index)">
            {{ faq.question }}
            <i class="fas" :class="faq.open ? 'fa-chevron-up' : 'fa-chevron-down'"></i>
          </div>
          <div class="faq-answer" v-show="faq.open">
            <p>{{ faq.answer }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
  <footer class="footer">
    <p style="margin: 0;">
      <a href="mailto:salmorejo2024@outlook.com">Contact</a>
      <span style="margin-left: 10px;">© 2025 UNHEIC.COM. All rights reserved.</span>
    </p>
  </footer>

  <!-- Error Message Component -->
  <ErrorMessage 
    :show="error.show" 
    :title="error.title" 
    :message="error.message" 
    :suggestion="error.suggestion"
    @close="closeError"
  />
</template>

<script>

import heic2any from "heic2any";
import JSZip from "jszip";
import ErrorMessage from "./components/ErrorMessage.vue";

export default {
  components: {
    ErrorMessage
  },
  mounted() {
    // Detect if it's a mobile device using user agent or touch capability
    const isMobileDevice = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    const isTouchDevice = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
    
    // Only show drop zone if it's not a mobile/touch device
    this.showDropZone = !(isMobileDevice || isTouchDevice);
  },
  data() {
    return {
      isDragging: false,
      files: [],
      isLoading: false,
      showDropZone: true,
      error: {
        show: false,
        title: '',
        message: '',
        suggestion: ''
      },
      faqs: [
        {
          question: "What is a HEIC file?",
          answer: "HEIC (High Efficiency Image Container) is a file format for images that uses more efficient compression than JPEG, resulting in smaller file sizes while maintaining higher image quality. It's commonly used by Apple devices since iOS 11.",
          open: false
        },
        {
          question: "Why would I need to convert HEIC to JPEG?",
          answer: "While HEIC offers better compression and quality, it's not universally supported. Converting to JPEG ensures compatibility with older devices, software, websites, and services that don't support HEIC files.",
          open: false
        },
        {
          question: "Is my data secure when using this service?",
          answer: "Yes! This service performs all conversions directly in your browser. Your files are never uploaded to any server, ensuring complete privacy and security. The conversion happens entirely on your device using JavaScript.",
          open: false
        },
        {
          question: "Will I lose image quality when converting?",
          answer: "There may be a slight quality reduction when converting from HEIC to JPEG due to the different compression methods used. However, for most everyday purposes, this difference is negligible.",
          open: false
        },
        {
          question: "Is there a limit to how many files I can convert?",
          answer: "There's no predetermined limit to the number of files you can convert. However, since processing happens on your device, converting a large number of high-resolution images might be slower depending on your device's capabilities.",
          open: false
        },
        {
          question: "What's the difference between JPEG and JPG?",
          answer: "There is no difference between JPEG and JPG. They are the exact same file format with different file extensions. JPEG stands for Joint Photographic Experts Group, which developed the standard. JPG is simply a three-letter abbreviation used in older operating systems that required three-character file extensions.",
          open: false
        }
      ]
    };
  },
  methods: {
    dragOver() {
      this.isDragging = true;
    },
    dragLeave() {
      this.isDragging = false;
    },
    dropFiles(event) {
      this.isDragging = false;
      const droppedFiles = event.dataTransfer.files;
      this.validateFiles(droppedFiles);
    },
    openFileDialog() {
      this.$refs.fileInput.click();
    },
    filesSelected(event) {
      const selectedFiles = event.target.files;
      this.validateFiles(selectedFiles);
    },
    validateFiles(fileList) {
      const validFiles = [];
      const invalidFiles = [];

      // Check if files were selected
      if (fileList.length === 0) {
        this.showError(
          'No Files Selected', 
          'No files were selected for upload.', 
          'Click the upload button to select HEIC files from your device.'
        );
        return;
      }

      for (let i = 0; i < fileList.length; i++) {
        const file = fileList[i];
        if (file.type === 'image/heic' || file.name.toLowerCase().endsWith('.heic')) {
          validFiles.push(file);
        } else {
          invalidFiles.push(file.name);
        }
      }

      // Handle invalid files with proper error message
      if (invalidFiles.length > 0) {
        const fileNames = invalidFiles.join(', ');
        const isPlural = invalidFiles.length > 1;
        this.showError(
          'Unsupported File Format', 
          `${fileNames} ${isPlural ? 'are' : 'is'} not in HEIC format.`, 
          'Only HEIC files can be converted. Please try again with files ending in .heic extension.'
        );
      }

      if (validFiles.length > 0) {
        this.files = [...this.files, ...validFiles];
      }
    },
    async convertFiles() {
      try {
        this.isLoading = true;

        if (this.files.length === 1) {
          await this.downloadConvertedFile(this.files[0]);
        } else if (this.files.length > 1) {
          await this.zipFiles(this.files);
        }

        this.isLoading = false;
        this.clearFiles();
      } catch (error) {
        this.isLoading = false;
        this.showError(
          'Conversion Failed',
          'There was an error during the conversion process.',
          'Try with smaller files or fewer files at once. Make sure your browser is up to date.'
        );
        console.error('Conversion error:', error);
      }
    },
    async downloadConvertedFile(file) {
      try {
        const jpegBlob = await heic2any({ blob: file, toType: "image/jpeg" });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(jpegBlob);
        link.download = file.name.replace(/\.heic$/i, '.jpg');
        link.click();
      } catch (error) {
        console.error('Download conversion error:', error);
        throw new Error(`Failed to convert ${file.name}: ${error.message}`);
      }
    },
    async zipFiles(files) {
      try {
        const zip = new JSZip();
        const failedFiles = [];

        for (const file of files) {
          try {
            const jpegBlob = await heic2any({ blob: file, toType: "image/jpeg" });
            zip.file(file.name.replace(/\.heic$/i, '.jpg'), jpegBlob);
          } catch (error) {
            console.error(`Failed to convert ${file.name}:`, error);
            failedFiles.push(file.name);
          }
        }

        if (failedFiles.length > 0 && failedFiles.length < files.length) {
          // Some files failed but not all
          this.showError(
            'Partial Conversion', 
            `Failed to convert ${failedFiles.join(', ')}. Other files were converted successfully.`,
            'The ZIP file will contain only the successfully converted files.'
          );
        } else if (failedFiles.length === files.length) {
          // All files failed
          throw new Error('All files failed to convert');
        }

        const zipBlob = await zip.generateAsync({ type: "blob" });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(zipBlob);
        link.download = "converted_files.zip";
        link.click();
      } catch (error) {
        console.error('Zip creation error:', error);
        throw new Error(`Failed to create ZIP file: ${error.message}`);
      }
    },
    clearFiles() {
      this.files = [];
      this.$refs.fileInput.value = null; 
    },
    removeFile(index) {
      this.files.splice(index, 1);
    },
    
    // Error handling methods
    showError(title, message, suggestion) {
      this.error = {
        show: true,
        title,
        message,
        suggestion
      };
      
      // Auto-hide error after 8 seconds
      setTimeout(() => {
        this.closeError();
      }, 8000);
    },
    
    closeError() {
      this.error.show = false;
    },
    toggleFaq(index) {
      this.faqs[index].open = !this.faqs[index].open;
    }
  }
}

</script>
