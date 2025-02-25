<template>
  <div id="app" class="container">
    <!-- Title area -->
    <div class="title-area">
      <h2>Convert HEIC to JPEG</h2>
      <p class="conversion-info">Fast, free, and completely private - your files never leave your device!</p>
    </div>

    <!-- Drop area -->
    <div class="drop-area" @dragover.prevent="dragOver" @dragleave.prevent="dragLeave" @drop.prevent="dropFiles"
      :class="{ dragover: isDragging }">

      <!-- Upload button -->
      <button class="upload-button btn" @click="openFileDialog">
        <i class="fas fa-upload"></i> Upload HEIC Files
      </button>
      <input type="file" ref="fileInput" @change="filesSelected" accept="image/heic" multiple>

      <div class="divider">or</div>
      <p class="drop-label">Drop files here</p>
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
  </div>
  <footer class="footer">
    <p><a href="mailto:salmorejo2024@outlook.com">Contact</a></p>
  </footer>
</template>

<script>

import heic2any from "heic2any";
import JSZip from "jszip";

export default {
  data() {
    return {
      isDragging: false,
      files: [],
      isLoading: false 
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
      for (let i = 0; i < fileList.length; i++) {
        const file = fileList[i];
        if (file.type === 'image/heic') {
          validFiles.push(file);
        } else {
          alert(`${file.name} is not a HEIC file.`);
        }
      }
      this.files = [...this.files, ...validFiles];
    },
    async convertFiles() {
      this.isLoading = true;

      if (this.files.length === 1) {
        await this.downloadConvertedFile(this.files[0]);
      } else if (this.files.length > 1) {
        await this.zipFiles(this.files);
      }

      this.isLoading = false;

      this.clearFiles();
    },
    async downloadConvertedFile(file) {
      const jpegBlob = await heic2any({ blob: file, toType: "image/jpeg" });
      const link = document.createElement('a');
      link.href = URL.createObjectURL(jpegBlob);
      link.download = file.name.replace(/\.heic$/i, '.jpg');
      link.click();
    },
    async zipFiles(files) {
      const zip = new JSZip();
      for (const file of files) {
        const jpegBlob = await heic2any({ blob: file, toType: "image/jpeg" });
        zip.file(file.name.replace(/\.heic$/i, '.jpg'), jpegBlob);
      }
      const zipBlob = await zip.generateAsync({ type: "blob" });
      const link = document.createElement('a');
      link.href = URL.createObjectURL(zipBlob);
      link.download = "converted_files.zip";
      link.click();
    },
    clearFiles() {
      this.files = [];
      this.$refs.fileInput.value = null; 
    },
    removeFile(index) {
      this.files.splice(index, 1);
    }
  }
}

</script>

