/**
 * DecideMeal / SoulFood Agent 客户端（HTML 原型）
 * 对接 soulfood-backed: /soulfood/ai/*
 */
(function (global) {
  'use strict';

  var STORAGE = {
    baseUrl: 'soulfood_api_base',
    conversationId: 'soulfood_conversation_id',
    preference: 'soulfood_taste_pref',
    voteContext: 'soulfood_vote_context',
    forceMock: 'soulfood_agent_mock'
  };

  var MOCK_RECIPES = [
    { name: '番茄炒蛋', score: '4.8', reason: '清淡下饭，适合多数人' },
    { name: '土豆丝炒肉', score: '4.6', reason: '家常菜，食材易得' },
    { name: '青菜鸡蛋面', score: '4.7', reason: '快手暖胃' }
  ];

  var MOCK_OPTIONS = ['寿司', '麻辣烫', '黄焖鸡'];
  var MOCK_PICK = { name: '海底捞(万象城店)', reason: '距离近、评分高，适合聚餐' };

  function getBaseUrl() {
    return localStorage.getItem(STORAGE.baseUrl) || 'http://localhost:8080/soulfood';
  }

  function isMockMode() {
    return localStorage.getItem(STORAGE.forceMock) === '1';
  }

  function delay(ms) {
    return new Promise(function (resolve) {
      setTimeout(resolve, ms);
    });
  }

  function buildPreference() {
    try {
      var raw = localStorage.getItem(STORAGE.preference);
      if (!raw) return '清淡、家常菜';
      var p = JSON.parse(raw);
      var parts = (p.tags || []).slice();
      if (p.spicy) parts.push('辣度' + p.spicy + '/5');
      if (p.sweet) parts.push('甜度' + p.sweet + '/5');
      if (p.noCoriander) parts.push('不吃香菜');
      if (p.noPeanut) parts.push('过滤花生过敏');
      return parts.length ? parts.join('、') : '清淡、家常菜';
    } catch (e) {
      return '清淡、家常菜';
    }
  }

  function getVoteContext() {
    try {
      var raw = sessionStorage.getItem(STORAGE.voteContext);
      return raw ? JSON.parse(raw) : null;
    } catch (e) {
      return null;
    }
  }

  function parseRecipesFromText(text) {
    if (!text) return [];
    var lines = text.split(/\n+/).filter(Boolean);
    var items = [];
    lines.forEach(function (line) {
      var m = line.match(/[【\[]?([^\]】\d]+?)[\]】]?[：:\-]?\s*(.+)?/);
      var name = (m && m[1] ? m[1] : line).replace(/^\d+[\.\)、\s]+/, '').trim();
      name = name.replace(/^[\-*•]\s*/, '').slice(0, 24);
      if (name.length < 2) return;
      var scoreMatch = line.match(/(\d\.\d)/);
      items.push({
        name: name,
        score: scoreMatch ? scoreMatch[1] : (4.5 + Math.random() * 0.3).toFixed(1),
        reason: (m && m[2]) ? m[2].trim().slice(0, 40) : 'AI 推荐'
      });
    });
    return items.slice(0, 5);
  }

  async function fetchJson(path, options) {
    var url = getBaseUrl().replace(/\/$/, '') + path;
    var res = await fetch(url, options);
    if (!res.ok) throw new Error('HTTP ' + res.status);
    return res.json();
  }

  var SoulFoodAgent = {
    getBaseUrl: getBaseUrl,
    setBaseUrl: function (url) {
      localStorage.setItem(STORAGE.baseUrl, url);
    },
    setMockMode: function (on) {
      localStorage.setItem(STORAGE.forceMock, on ? '1' : '0');
    },
    getConversationId: function () {
      return localStorage.getItem(STORAGE.conversationId);
    },
    setConversationId: function (id) {
      if (id) localStorage.setItem(STORAGE.conversationId, id);
    },
    getPreference: buildPreference,
    savePreference: function (data) {
      localStorage.setItem(STORAGE.preference, JSON.stringify(data));
    },
    setVoteContext: function (ctx) {
      sessionStorage.setItem(STORAGE.voteContext, JSON.stringify(ctx));
    },
    getVoteContext: getVoteContext,

    /** GET /ai/recommend */
    recommend: async function (extraPreference) {
      if (isMockMode()) {
        await delay(600);
        return { source: 'mock', text: MOCK_RECIPES.map(function (r) {
          return r.name + '：' + r.reason;
        }).join('\n') };
      }
      var pref = buildPreference();
      if (extraPreference) pref += '、' + extraPreference;
      var ctx = getVoteContext();
      if (ctx && ctx.winner) pref += '、投票结果偏向' + ctx.winner;
      var q = encodeURIComponent(pref);
      try {
        var data = await fetchJson('/ai/recommend?preference=' + q);
        return { source: 'api', text: data.reply || '', conversationId: data.conversationId };
      } catch (err) {
        await delay(400);
        return { source: 'mock-fallback', text: MOCK_RECIPES.map(function (r) {
          return '1. ' + r.name + '：' + r.reason;
        }).join('\n'), error: err.message };
      }
    },

    /** POST /ai/chat */
    chat: async function (message) {
      if (isMockMode()) {
        await delay(500);
        return { conversationId: 'mock', reply: '好的，我建议你们吃「' + (getVoteContext()?.winner || '火锅') + '」。' };
      }
      var body = {
        message: message,
        conversationId: SoulFoodAgent.getConversationId()
      };
      try {
        var data = await fetchJson('/ai/chat', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body)
        });
        if (data.conversationId) SoulFoodAgent.setConversationId(data.conversationId);
        return data;
      } catch (err) {
        return { conversationId: null, reply: '（离线演示）今天可以试试番茄炒蛋配米饭。', error: err.message };
      }
    },

    recommendRecipes: async function (opts) {
      opts = opts || {};
      var extra = opts.extraPreference || '';
      var res = await SoulFoodAgent.recommend(extra);
      var items = parseRecipesFromText(res.text);
      if (!items.length) items = MOCK_RECIPES.slice();
      return { items: items, raw: res.text, source: res.source };
    },

    suggestVoteOptions: async function (topic) {
      if (isMockMode()) {
        await delay(500);
        return { options: MOCK_OPTIONS, source: 'mock' };
      }
      var prompt = '请为聚餐主题「' + (topic || '今晚吃什么') + '」生成3个简短投票选项，每行一个，不要编号说明';
      var data = await SoulFoodAgent.chat(prompt);
      var options = parseRecipesFromText(data.reply || '').map(function (x) { return x.name; });
      if (!options.length) {
        options = (data.reply || '').split(/\n/).map(function (s) {
          return s.replace(/^\d+[\.\)、\s]+/, '').trim();
        }).filter(function (s) { return s.length >= 2 && s.length <= 12; });
      }
      if (!options.length) options = MOCK_OPTIONS;
      return { options: options.slice(0, 4), source: data.error ? 'mock-fallback' : 'api' };
    },

    randomPick: async function (candidates) {
      candidates = candidates || [];
      if (isMockMode() || !candidates.length) {
        await delay(500);
        var pick = candidates[Math.floor(Math.random() * candidates.length)] || MOCK_PICK.name;
        return { name: pick, reason: '随机抽签 + AI 兜底推荐', source: 'mock' };
      }
      var prompt = '从以下餐厅中推荐今天去吃的一家，只返回店名和一句话理由：' + candidates.join('、');
      var data = await SoulFoodAgent.chat(prompt);
      var first = (data.reply || '').split('\n')[0] || '';
      var name = candidates.find(function (c) { return first.indexOf(c) >= 0; }) || candidates[0];
      return { name: name, reason: first.slice(0, 60), source: 'api' };
    },

    /** UI helpers */
    showToast: function (phoneEl, message, type) {
      var root = phoneEl || document.querySelector('.phone');
      if (!root) return;
      var old = root.querySelector('.agent-toast');
      if (old) old.remove();
      var el = document.createElement('div');
      el.className = 'agent-toast' + (type ? ' ' + type : '');
      el.textContent = message;
      root.appendChild(el);
      setTimeout(function () { el.remove(); }, 2800);
    },

    setLoading: function (btn, loading, loadingText) {
      if (!btn) return;
      if (loading) {
        btn.dataset.prevText = btn.textContent;
        btn.disabled = true;
        btn.classList.add('is-loading');
        btn.textContent = loadingText || 'AI 思考中...';
      } else {
        btn.disabled = false;
        btn.classList.remove('is-loading');
        btn.textContent = btn.dataset.prevText || btn.textContent;
      }
    },

    renderRecipeList: function (listEl, items) {
      if (!listEl) return;
      var icons = ['breakfast_dining', 'lunch_dining', 'ramen_dining', 'dinner_dining', 'local_pizza'];
      var thumbs = ['thumb-tomato', 'thumb-potato', 'thumb-noodle', 'thumb-hotpot', 'thumb-bbq'];
      listEl.innerHTML = items.map(function (item, i) {
        return '<li>' +
          '<span class="option-left">' +
          '<span class="food-thumb ' + thumbs[i % thumbs.length] + '">' +
          '<span class="material-symbols-outlined">' + icons[i % icons.length] + '</span></span>' +
          (item.name || '推荐菜') +
          '</span>' +
          '<span title="' + (item.reason || '') + '">评分 ' + (item.score || '4.5') + '</span>' +
          '</li>';
      }).join('');
    }
  };

  global.SoulFoodAgent = SoulFoodAgent;
})(typeof window !== 'undefined' ? window : this);
