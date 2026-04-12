// vyantra-core.js - Universal Template Core Platform v1.0.9-PRO
// Encapsulates Supabase initialization, property extraction, and common utilities.

(function() {
  'use strict';

  var VYANTRA_VERSION = "1.0.9";

  // ============================================================
  // VYANTRA ERROR REGISTRY (VY-ERR-001 to 012)
  // ============================================================
  var VyantraErrors = {
    'VY-ERR-001': { code: 'VY-ERR-001', title: 'Property Not Configured', message: 'Property context missing. Contact admin or check URL.', type: 'critical' },
    'VY-ERR-002': { code: 'VY-ERR-002', title: 'Connection Timeout', message: 'Database taking too long. Check internet connection.', type: 'warning' },
    'VY-ERR-003': { code: 'VY-ERR-003', title: 'Auth Token Expired', message: 'Session expired. Please log in again.', type: 'auth' },
    'VY-ERR-004': { code: 'VY-ERR-004', title: 'Rate Limit Exceeded', message: 'Too many requests. Please pause for 5 minutes.', type: 'warning' },
    'VY-ERR-005': { code: 'VY-ERR-005', title: 'Invalid Date Range', message: 'Check-out must be after check-in date.', type: 'validation' },
    'VY-ERR-006': { code: 'VY-ERR-006', title: 'Database Write Failed', message: 'Could not save changes. Please try again.', type: 'error' },
    'VY-ERR-007': { code: 'VY-ERR-007', title: 'RLS Security Violation', message: 'You do not have permission to access this data.', type: 'security' },
    'VY-ERR-008': { code: 'VY-ERR-008', title: 'Concurrent Booking Conflict', message: 'Room was just booked. Please select different dates.', type: 'conflict' },
    'VY-ERR-009': { code: 'VY-ERR-009', title: 'Database Linter Warning', message: 'Server busy. Please wait and try again.', type: 'warning' },
    'VY-ERR-010': { code: 'VY-ERR-010', title: 'Room Not Available', message: 'No rooms available for selected dates.', type: 'validation' },
    'VY-ERR-011': { code: 'VY-ERR-011', title: 'Invalid Input', message: 'Please fill in all required fields.', type: 'validation' },
    'VY-ERR-012': { code: 'VY-ERR-012', title: 'Network Error', message: 'Please check your internet connection.', type: 'error' }
  };

  function showVyantraToast(errorCode, customMessage) {
    var error = VyantraErrors[errorCode] || VyantraErrors['VY-ERR-012'];
    var toast = document.getElementById('vyantraToast');
    if (!toast) {
      toast = document.createElement('div');
      toast.id = 'vyantraToast';
      toast.style.cssText = 'position:fixed;top:80px;right:20px;background:#1a1d23;border:1px solid #d4a843;border-radius:10px;padding:16px 24px;z-index:99999;font-family:sans-serif;max-width:400px;box-shadow:0 8px 32px rgba(0,0,0,0.3);';
      document.body.appendChild(toast);
    }
    var icon = error.type === 'warning' ? 'fa-exclamation-triangle' : error.type === 'auth' ? 'fa-lock' : error.type === 'validation' ? 'fa-calendar-times' : 'fa-exclamation-circle';
    var iconColor = error.type === 'warning' ? '#fbbf24' : error.type === 'auth' ? '#60a5fa' : error.type === 'validation' ? '#f97316' : '#f87171';
    toast.innerHTML = '<i class="fas ' + icon + '" style="color:' + iconColor + ';margin-right:10px;"></i><span style="font-weight:600;color:#fff;">' + error.title + '</span><p style="margin:8px 0 0 24px;font-size:0.85rem;color:#aaa;">' + (customMessage || error.message) + '</p>';
    toast.style.display = 'block';
    setTimeout(function() { toast.style.display = 'none'; }, 8000);
    return error;
  }

  function throwVyantraError(code, customMessage) {
    console.error('VyantraError [' + code + ']:', customMessage);
    showVyantraToast(code, customMessage);
    return VyantraErrors[code] || VyantraErrors['VY-ERR-010'];
  }

  var VyantraCore = {
    // 1. Property ID - Universal Engine (NO hardcoded fallbacks)
    getPropertyId: function() {
      if (window.VYANTRA_PROP_ID && /^[a-zA-Z0-9_]+$/.test(window.VYANTRA_PROP_ID)) { return window.VYANTRA_PROP_ID; }
      if (window.location) { var params = new URLSearchParams(window.location.search); var prop = params.get('property'); if (prop && /^[a-zA-Z0-9_]+$/.test(prop)) { return prop; } }
      throwVyantraError('VY-ERR-001');
      throw new Error('VY-ERR-001: Property not configured');
    },

    getReturnUrl: function(defaultUrl) {
      if (!window.location) return defaultUrl;
      var params = new URLSearchParams(window.location.search);
      var rUrl = params.get('return_url');
      if (rUrl && (rUrl.startsWith('http://') || rUrl.startsWith('https://') || rUrl.startsWith('/'))) { return rUrl; }
      return defaultUrl || 'index.html';
    },

    getRoomId: function() {
      if (!window.location) return null;
      var params = new URLSearchParams(window.location.search);
      var id = params.get('room_id');
      if (id && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id)) { return id; }
      return null;
    },

    // 2. Safe Supabase Initialization
    initSupabase: function(supabaseUrl, supabaseKey) {
      if (!window.supabase) { 
        console.error('VyantraCore: Supabase library not loaded');
        throwVyantraError('VY-ERR-002', 'Supabase library not loaded');
        return null; 
      }
      try {
        var client = window.supabase.createClient(supabaseUrl, supabaseKey, {
          auth: { 
            persistSession: true,
            autoRefreshToken: true
          },
          global: {
            headers: {
              'x-client-info': 'vyantra-core'
            }
          }
        });
        return client;
      } catch(e) {
        console.error('VyantraCore init error:', e);
        throwVyantraError('VY-ERR-002', 'Failed to initialize database connection');
        return null;
      }
    },

    // 3. Error Handling
    handleApiError: function(err, customMessage) {
      if (err && err.message) {
        var msg = err.message.toLowerCase();
        if (msg.includes('rate limit')) { 
          throwVyantraError('VY-ERR-004'); 
          return "Too many requests. Please wait."; 
        }
        if (msg.includes('connection') || msg.includes('fetch') || msg.includes('network') || msg.includes('timeout')) {
          throwVyantraError('VY-ERR-002', 'Cannot connect to database. Check internet connection.');
          return "Connection error. Please check your internet.";
        }
        if (err.message.includes('VY-ERR-002')) { throwVyantraError('VY-ERR-002'); }
        if (err.message.includes('JWT') || err.code === 'PGRST116') { throwVyantraError('VY-ERR-003'); }
      }
      showVyantraToast('VY-ERR-010', customMessage || 'An error occurred');
      return customMessage || "An error occurred.";
    },
    
    // 4. Connection Test
    testConnection: function(supabase, callback) {
      if (!supabase) {
        callback(false, 'No database connection');
        return;
      }
      supabase.from('rooms').select('id').limit(1).then(function(resp) {
        if (resp.error) {
          callback(false, resp.error.message);
        } else {
          callback(true, null);
        }
      });
    },

    // 4. WhatsApp Link Builder
    buildWhatsAppLink: function(phone, rawMessage) {
      if (!phone) return '#';
      var cleanPhone = phone.replace(/[\s\+\-()]/g, '');
      if (!/^91/.test(cleanPhone)) cleanPhone = '91' + cleanPhone;
      return 'https://wa.me/' + cleanPhone + '?text=' + encodeURIComponent(rawMessage);
    },

    // 5. Room Change Tracker
    roomChanges: {},
    trackRoomChange: function(roomId, field, value) {
      if (!this.roomChanges[roomId]) { this.roomChanges[roomId] = {}; }
      this.roomChanges[roomId][field] = value;
    },
    getRoomChanges: function() { return this.roomChanges; },
    clearRoomChanges: function() { this.roomChanges = {}; },

    // 6. Feedback Link Generator
    generateFeedbackLink: function(bookingId, propertyName) {
      if (!bookingId) return '#';
      var baseUrl = window.location.origin + window.location.pathname;
      baseUrl = baseUrl.replace(/admin\.html|booking\.html$/, 'guest-portal.html');
      var url = baseUrl + '?booking=' + encodeURIComponent(bookingId);
      if (propertyName) { url += '&property=' + encodeURIComponent(propertyName); }
      return url;
    },

    // 7. Version Getter
    getVersion: function() { return VYANTRA_VERSION; },

    // 8. Error Registry Getter
    getErrors: function() { return VyantraErrors; },

    // 9. Throw Error
    throwError: function(code, customMessage) { throwVyantraError(code, customMessage); },

    // 10. Date Validation
    validateDates: function(checkIn, checkOut) {
      if (!checkIn || !checkOut) { throwVyantraError('VY-ERR-008', 'Please select check-in and check-out dates'); return false; }
      if (new Date(checkOut) <= new Date(checkIn)) { throwVyantraError('VY-ERR-005'); return false; }
      return true;
    }
  };

  window.VyantraCore = VyantraCore;
  window.VYANTRA_VERSION = VYANTRA_VERSION;
  window.throwVyantraError = throwVyantraError;
})();