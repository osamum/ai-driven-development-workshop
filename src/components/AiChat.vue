<template>
  <div class="ai-chat">
    <div class="chat-header">
      <h2>AI チャット - 工場設備管理アシスタント</h2>
      <p class="chat-description">設備の運用、保全、効率化に関する質問にお答えします。</p>
    </div>

    <!-- チャット履歴エリア -->
    <div class="chat-messages" ref="messagesContainer">
      <div v-if="isLoading && messages.length === 0" class="loading-message">
        <div class="spinner"></div>
        <span>履歴を読み込み中...</span>
      </div>

      <div v-for="message in messages" :key="message.id" class="message-group">
        <!-- ユーザーメッセージ -->
        <div class="message user-message">
          <div class="message-content">
            <div class="message-text">{{ message.userMessage }}</div>
            <div class="message-time">{{ formatTime(message.timestamp) }}</div>
          </div>
          <div class="message-avatar user-avatar">👤</div>
        </div>

        <!-- AIレスポンス -->
        <div class="message ai-message">
          <div class="message-avatar ai-avatar">🤖</div>
          <div class="message-content">
            <div class="message-text" v-html="formatAIResponse(message.aiResponse)"></div>
            <div class="message-time">{{ formatTime(message.timestamp) }}</div>
          </div>
        </div>
      </div>

      <div v-if="isTyping" class="message ai-message typing">
        <div class="message-avatar ai-avatar">🤖</div>
        <div class="message-content">
          <div class="typing-indicator">
            <span></span>
            <span></span>
            <span></span>
          </div>
        </div>
      </div>
    </div>

    <!-- エラーメッセージ -->
    <div v-if="errorMessage" class="error-message">
      <p>{{ errorMessage }}</p>
      <button @click="clearError" class="btn btn-primary">閉じる</button>
    </div>

    <!-- メッセージ入力エリア -->
    <div class="chat-input">
      <div class="input-group">
        <textarea 
          v-model="newMessage" 
          @keydown.enter.prevent="sendMessage"
          @keydown.shift.enter="addNewLine"
          placeholder="質問を入力してください（Enterで送信、Shift+Enterで改行）"
          rows="2"
          :disabled="isTyping"
          ref="messageInput"
        ></textarea>
        <button 
          @click="sendMessage" 
          :disabled="!newMessage.trim() || isTyping"
          class="btn btn-primary send-button"
        >
          <span v-if="isTyping">送信中...</span>
          <span v-else>送信</span>
        </button>
      </div>
    </div>

    <!-- デモ用のサンプル質問 -->
    <div class="sample-questions" v-if="messages.length === 0">
      <h3>サンプル質問</h3>
      <div class="sample-buttons">
        <button 
          v-for="sample in sampleQuestions" 
          :key="sample"
          @click="askSampleQuestion(sample)"
          class="btn sample-btn"
          :disabled="isTyping"
        >
          {{ sample }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import apiService from '../services/api-service.js'

export default {
  name: 'AiChat',
  data() {
    return {
      messages: [],
      newMessage: '',
      isLoading: false,
      isTyping: false,
      errorMessage: '',
      sessionId: 'default',
      sampleQuestions: [
        '設備の稼働状況を教えて',
        '保全スケジュールの確認方法は？',
        'アラートが発生した時の対応手順',
        '効率化のための提案が欲しい',
        'センサーデータの見方を教えて'
      ]
    }
  },
  async mounted() {
    await this.loadChatHistory()
  },
  methods: {
    async loadChatHistory() {
      this.isLoading = true
      try {
        const response = await apiService.getChatHistory(this.sessionId, 20)
        if (response.success) {
          this.messages = response.history.reverse() // 古い順に並び替え
        }
      } catch (error) {
        console.error('履歴読み込みエラー:', error)
        this.errorMessage = '履歴の読み込みに失敗しました'
      } finally {
        this.isLoading = false
        this.$nextTick(() => {
          this.scrollToBottom()
        })
      }
    },

    async sendMessage() {
      if (!this.newMessage.trim() || this.isTyping) return

      const userMessage = this.newMessage.trim()
      this.newMessage = ''
      this.isTyping = true
      this.clearError()

      try {
        const response = await apiService.sendChatMessage(userMessage, this.sessionId)
        
        if (response.success) {
          const messageEntry = {
            id: response.chatId,
            sessionId: response.sessionId,
            userMessage: userMessage,
            aiResponse: response.response,
            timestamp: response.timestamp
          }
          
          this.messages.push(messageEntry)
          
          this.$nextTick(() => {
            this.scrollToBottom()
          })
        } else {
          throw new Error(response.error || 'メッセージの送信に失敗しました')
        }
      } catch (error) {
        console.error('チャットエラー:', error)
        this.errorMessage = `エラーが発生しました: ${error.message}`
      } finally {
        this.isTyping = false
        this.$refs.messageInput.focus()
      }
    },

    askSampleQuestion(question) {
      this.newMessage = question
      this.sendMessage()
    },

    addNewLine() {
      this.newMessage += '\n'
    },

    scrollToBottom() {
      const container = this.$refs.messagesContainer
      if (container) {
        container.scrollTop = container.scrollHeight
      }
    },

    formatTime(timestamp) {
      const date = new Date(timestamp)
      return date.toLocaleTimeString('ja-JP', { 
        hour: '2-digit', 
        minute: '2-digit' 
      })
    },

    formatAIResponse(response) {
      // 簡単なマークダウン風の文字装飾
      return response
        .replace(/\n/g, '<br>')
        .replace(/•\s/g, '• ')
        .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    },

    clearError() {
      this.errorMessage = ''
    }
  }
}
</script>

<style scoped>
.ai-chat {
  max-width: 800px;
  margin: 0 auto;
  height: calc(100vh - 200px);
  display: flex;
  flex-direction: column;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  overflow: hidden;
}

.chat-header {
  padding: 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  text-align: center;
}

.chat-header h2 {
  margin: 0;
  font-size: 1.5rem;
}

.chat-description {
  margin: 0.5rem 0 0 0;
  opacity: 0.9;
  font-size: 0.9rem;
}

.chat-messages {
  flex: 1;
  padding: 1rem;
  overflow-y: auto;
  background: #f8f9fa;
}

.loading-message {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  padding: 2rem;
  color: #666;
}

.spinner {
  width: 20px;
  height: 20px;
  border: 2px solid #e0e0e0;
  border-top: 2px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.message-group {
  margin-bottom: 1.5rem;
}

.message {
  display: flex;
  margin-bottom: 0.5rem;
  align-items: flex-start;
  gap: 0.75rem;
}

.user-message {
  flex-direction: row-reverse;
}

.message-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  flex-shrink: 0;
}

.user-avatar {
  background: #007bff;
}

.ai-avatar {
  background: #28a745;
}

.message-content {
  max-width: 70%;
  background: white;
  border-radius: 12px;
  padding: 0.75rem 1rem;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.user-message .message-content {
  background: #007bff;
  color: white;
}

.message-text {
  margin-bottom: 0.25rem;
  line-height: 1.4;
  word-wrap: break-word;
}

.message-time {
  font-size: 0.75rem;
  opacity: 0.7;
}

.typing-indicator {
  display: flex;
  gap: 0.25rem;
  align-items: center;
  padding: 0.5rem 0;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #666;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-indicator span:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes typing {
  0%, 60%, 100% {
    transform: scale(0.7);
    opacity: 0.5;
  }
  30% {
    transform: scale(1);
    opacity: 1;
  }
}

.error-message {
  padding: 1rem;
  background: #f8d7da;
  color: #721c24;
  border-left: 4px solid #dc3545;
  margin: 1rem;
  border-radius: 4px;
}

.chat-input {
  padding: 1rem;
  background: white;
  border-top: 1px solid #e0e0e0;
}

.input-group {
  display: flex;
  gap: 0.75rem;
  align-items: flex-end;
}

.input-group textarea {
  flex: 1;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  resize: none;
  font-family: inherit;
  font-size: 1rem;
  line-height: 1.4;
}

.input-group textarea:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 2px rgba(0,123,255,0.25);
}

.send-button {
  padding: 0.75rem 1.5rem;
  white-space: nowrap;
}

.sample-questions {
  padding: 1rem;
  background: #f8f9fa;
  border-top: 1px solid #e0e0e0;
}

.sample-questions h3 {
  margin: 0 0 1rem 0;
  font-size: 1rem;
  color: #666;
}

.sample-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.sample-btn {
  padding: 0.5rem 1rem;
  background: white;
  border: 1px solid #ddd;
  border-radius: 20px;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
}

.sample-btn:hover:not(:disabled) {
  background: #007bff;
  color: white;
  border-color: #007bff;
}

.sample-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .ai-chat {
    height: calc(100vh - 140px);
    margin: 0;
    border-radius: 0;
  }
  
  .message-content {
    max-width: 85%;
  }
  
  .sample-buttons {
    flex-direction: column;
  }
  
  .sample-btn {
    text-align: left;
    border-radius: 8px;
  }
}
</style>