// lib/screens/ai_assistant_screen.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// Data model for a single chat message
// ─────────────────────────────────────────────────────────────
class _Msg {
  final bool isUser;
  final String text;
  final Uint8List? imageBytes; // only for user messages with images
  final bool isTyping;         // placeholder while AI responds

  const _Msg({
    required this.isUser,
    required this.text,
    this.imageBytes,
    this.isTyping = false,
  });
}

// ─────────────────────────────────────────────────────────────
// Quick prompt chips shown on the welcome state
// ─────────────────────────────────────────────────────────────
const _kSuggestions = [
  ('📅', 'Create a 7-day study plan for my exams'),
  ('🧮', 'Explain quadratic equations with examples'),
  ('⏱️', 'Best time management techniques for students'),
  ('🔬', 'Summarise the theory of evolution'),
  ('📝', 'How do I write a strong essay introduction?'),
  ('🧠', 'What is the Pomodoro technique and does it work?'),
];

// ─────────────────────────────────────────────────────────────
// AI Assistant Screen
// ─────────────────────────────────────────────────────────────
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker     = ImagePicker();
  final _focusNode  = FocusNode();

  final List<_Msg>  _messages  = [];
  Uint8List?        _pendingImage;
  bool              _loading   = false;
  late AnimationController _shimmerCtrl;

  // History sent to API: list of {role, content} maps
  final List<Map<String, dynamic>> _apiHistory = [];

  static const _systemPrompt = '''
You are EduMentor, an expert AI academic assistant embedded inside the Edu Planner app.
Your role is to help students in three key areas:

1. ACADEMIC HELP — Solve problems, explain concepts, and teach any subject
   (Math, Physics, Chemistry, Biology, History, Literature, Programming, etc.)
   Step through solutions clearly. Use examples, analogies, and diagrams described in text.

2. STUDY PLANNING — Build personalised study schedules, revision timetables,
   exam prep strategies, and daily routines based on the student's goals and deadlines.

3. TIME MANAGEMENT — Recommend evidence-based techniques (Pomodoro, time-blocking,
   spaced repetition, active recall, etc.) and help the student optimise their productivity.

Formatting rules:
- Use clear headings with emoji (e.g. "📘 Solution:", "📅 Study Plan:")
- Use numbered steps for multi-step solutions
- Use bullet points for lists
- Wrap code in triple backticks with the language name
- Be encouraging, concise, and student-friendly
- If an image is provided, analyse it and answer based on its content
- Always end with a short motivational note or a follow-up question to keep engagement
''';

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── Scroll to bottom ──────────────────────────────────────
  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Pick image ────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close bottom sheet
    try {
      final file = await _picker.pickImage(
          source: source, imageQuality: 80, maxWidth: 1024);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() => _pendingImage = bytes);
    } catch (_) {}
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2))),
          ListTile(
            leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.accent)),
            title: const Text('Take a photo',
                style: TextStyle(color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600)),
            subtitle: const Text('Use your camera',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onTap: () => _pickImage(ImageSource.camera),
          ),
          ListTile(
            leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.photo_library_rounded,
                    color: AppColors.purple)),
            title: const Text('Choose from gallery',
                style: TextStyle(color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600)),
            subtitle: const Text('Pick an existing image',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  // ── Send message ──────────────────────────────────────────
  Future<void> _send([String? override]) async {
    final text = (override ?? _controller.text).trim();
    if ((text.isEmpty && _pendingImage == null) || _loading) return;

    final imageBytes = _pendingImage;
    _controller.clear();
    setState(() {
      _pendingImage = null;
      _loading = true;
      _messages.add(_Msg(
          isUser: true, text: text, imageBytes: imageBytes));
      _messages.add(const _Msg(isUser: false, text: '', isTyping: true));
    });
    _scrollDown();

    try {
      final reply = await _callClaude(text, imageBytes);
      setState(() {
        _messages.removeLast(); // remove typing indicator
        _messages.add(_Msg(isUser: false, text: reply));
        _loading = false;
      });
      // Add to history for multi-turn context
      _apiHistory.add({'role': 'user',
        'content': _buildUserContent(text, imageBytes)});
      _apiHistory.add({'role': 'assistant',
        'content': reply});
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(_Msg(
            isUser: false,
            text: '⚠️ Sorry, I couldn\'t connect right now.\n\n'
                'Please check your internet connection and try again.\n\n'
                '_Error: ${e.toString()}_'));
        _loading = false;
      });
    }
    _scrollDown();
  }

  // ── Build user content (text + optional image) ─────────────
  dynamic _buildUserContent(String text, Uint8List? image) {
    if (image == null) return text;
    return [
      {
        'type': 'image',
        'source': {
          'type': 'base64',
          'media_type': 'image/jpeg',
          'data': base64Encode(image),
        },
      },
      if (text.isNotEmpty) {'type': 'text', 'text': text},
      if (text.isEmpty)    {'type': 'text', 'text': 'Please analyse this image and help me.'},
    ];
  }

  // ── Call Anthropic API ────────────────────────────────────
  Future<String> _callClaude(String text, Uint8List? image) async {
    // Build messages list: history + new user message
    final messages = [
      ..._apiHistory,
      {
        'role': 'user',
        'content': _buildUserContent(text, image),
      }
    ];

    final response = await http
        .post(
          Uri.parse('https://api.anthropic.com/v1/messages'),
          headers: {
            'Content-Type': 'application/json',
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode({
            'model': 'claude-sonnet-4-6',
            'max_tokens': 2048,
            'system': _systemPrompt,
            'messages': messages,
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['content'] as List;
      return content
          .where((b) => b['type'] == 'text')
          .map((b) => b['text'] as String)
          .join('\n');
    } else {
      throw Exception('API error ${response.statusCode}: ${response.body}');
    }
  }

  // ── Clear chat ────────────────────────────────────────────
  void _clearChat() {
    setState(() {
      _messages.clear();
      _apiHistory.clear();
      _pendingImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final empty = _messages.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        // ── Header ──────────────────────────────────────────
        _Header(onClear: empty ? null : _clearChat),

        // ── Messages / Welcome ───────────────────────────────
        Expanded(
          child: empty ? _WelcomeView(onSuggest: _send) : _MessageList(
            messages: _messages,
            scrollCtrl: _scrollCtrl,
            shimmerCtrl: _shimmerCtrl,
          ),
        ),

        // ── Pending image preview ────────────────────────────
        if (_pendingImage != null)
          _ImagePreview(
            bytes: _pendingImage!,
            onRemove: () => setState(() => _pendingImage = null),
          ),

        // ── Input bar ────────────────────────────────────────
        _InputBar(
          controller: _controller,
          focusNode: _focusNode,
          loading: _loading,
          hasImage: _pendingImage != null,
          onPickImage: _showImagePicker,
          onSend: _send,
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback? onClear;
  const _Header({this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 16, 14),
      decoration: const BoxDecoration(
        gradient: AppColors.gradientDark,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(children: [
        // AI avatar
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D9A3), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
                color: AppColors.accent.withOpacity(0.35),
                blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EduMentor AI',
                style: TextStyle(color: AppColors.textPrimary,
                    fontSize: 17, fontWeight: FontWeight.w800)),
            Row(children: [
              Container(
                  width: 7, height: 7,
                  decoration: const BoxDecoration(
                      color: AppColors.green, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              const Text('Online · Academic Expert',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ]),
          ],
        )),
        if (onClear != null)
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded,
                color: AppColors.textSecondary),
            tooltip: 'Clear chat',
            onPressed: onClear,
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Welcome / Empty State
// ─────────────────────────────────────────────────────────────
class _WelcomeView extends StatelessWidget {
  final ValueChanged<String> onSuggest;
  const _WelcomeView({required this.onSuggest});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(children: [
        // Hero
        Container(
          width: 110, height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00D9A3), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(
                color: AppColors.accent.withOpacity(0.3),
                blurRadius: 30, spreadRadius: 5)],
          ),
          child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 52))),
        ),
        const SizedBox(height: 20),
        const Text('Hi, I\'m EduMentor!',
            style: TextStyle(color: AppColors.textPrimary,
                fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text(
          'Your personal AI academic assistant.\nAsk me anything — I\'m here to help you succeed.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary,
              fontSize: 14, height: 1.55),
        ),
        const SizedBox(height: 28),

        // Capability chips
        Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
          _Cap('📚', 'Solve Problems'),
          const SizedBox(width: 8),
          _Cap('📅', 'Study Plans'),
          const SizedBox(width: 8),
          _Cap('🖼️', 'Analyse Images'),
        ]),
        const SizedBox(height: 28),

        // Suggestions
        Align(
          alignment: Alignment.centerLeft,
          child: const Text('Try asking:',
              style: TextStyle(color: AppColors.textSecondary,
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        ..._kSuggestions.map((s) => _SuggestionTile(
            emoji: s.$1, text: s.$2, onTap: () => onSuggest(s.$2))),
      ]),
    );
  }
}

class _Cap extends StatelessWidget {
  final String emoji, label;
  const _Cap(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String emoji, text;
  final VoidCallback onTap;
  const _SuggestionTile(
      {required this.emoji, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(text,
              style: const TextStyle(color: AppColors.textPrimary,
                  fontSize: 13, fontWeight: FontWeight.w500))),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: AppColors.textSecondary, size: 13),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Message List
// ─────────────────────────────────────────────────────────────
class _MessageList extends StatelessWidget {
  final List<_Msg> messages;
  final ScrollController scrollCtrl;
  final AnimationController shimmerCtrl;

  const _MessageList({
    required this.messages,
    required this.scrollCtrl,
    required this.shimmerCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[i];
        if (msg.isTyping) return _TypingBubble(shimmerCtrl: shimmerCtrl);
        return msg.isUser
            ? _UserBubble(msg: msg)
            : _AiBubble(msg: msg);
      },
    );
  }
}

// ── User Bubble ───────────────────────────────────────────────
class _UserBubble extends StatelessWidget {
  final _Msg msg;
  const _UserBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (msg.imageBytes != null)
                  GestureDetector(
                    onTap: () => _showFullImage(context, msg.imageBytes!),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(msg.imageBytes!,
                            width: 200, height: 160,
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                if (msg.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientAccent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(4),
                      ),
                      boxShadow: [BoxShadow(
                          color: AppColors.accent.withOpacity(0.25),
                          blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Text(msg.text,
                        style: const TextStyle(
                            color: AppColors.bg,
                            fontSize: 14, fontWeight: FontWeight.w500,
                            height: 1.5)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.gradientAccent,
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Text('👤', style: TextStyle(fontSize: 16))),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext ctx, Uint8List bytes) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(bytes, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

// ── AI Bubble ─────────────────────────────────────────────────
class _AiBubble extends StatelessWidget {
  final _Msg msg;
  const _AiBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D9A3), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: _FormattedText(text: msg.text),
                ),
                const SizedBox(height: 5),
                Row(children: [
                  const Text('EduMentor',
                      style: TextStyle(color: AppColors.textSecondary,
                          fontSize: 10)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: msg.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard'),
                            duration: Duration(seconds: 1)));
                    },
                    child: const Row(children: [
                      Icon(Icons.copy_rounded,
                          color: AppColors.textSecondary, size: 11),
                      SizedBox(width: 3),
                      Text('Copy', style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 10)),
                    ]),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Typing Indicator ──────────────────────────────────────────
class _TypingBubble extends StatelessWidget {
  final AnimationController shimmerCtrl;
  const _TypingBubble({required this.shimmerCtrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF00D9A3), Color(0xFF8B5CF6)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(color: AppColors.divider),
          ),
          child: AnimatedBuilder(
            animation: shimmerCtrl,
            builder: (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.2;
                final t = (shimmerCtrl.value - delay).clamp(0.0, 1.0);
                final scale = 0.6 + 0.4 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.4 + 0.6 * scale),
                    shape: BoxShape.circle,
                  ),
                  transform: Matrix4.identity()
                    ..translate(0.0, -4.0 * (scale - 0.6) / 0.4),
                );
              }),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Formatted AI text — handles headers, bullets, code blocks
// ─────────────────────────────────────────────────────────────
class _FormattedText extends StatelessWidget {
  final String text;
  const _FormattedText({required this.text});

  @override
  Widget build(BuildContext context) {
    final segments = _parse(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((s) => s.build(context)).toList(),
    );
  }

  List<_Seg> _parse(String raw) {
    final segments = <_Seg>[];
    final lines = raw.split('\n');
    bool inCode = false;
    String codeLang = '';
    final codeLines = <String>[];

    for (final line in lines) {
      if (line.startsWith('```')) {
        if (!inCode) {
          inCode = true;
          codeLang = line.substring(3).trim();
        } else {
          segments.add(_CodeSeg(codeLines.join('\n'), codeLang));
          codeLines.clear();
          inCode = false;
          codeLang = '';
        }
        continue;
      }
      if (inCode) {
        codeLines.add(line);
        continue;
      }
      if (line.startsWith('### ')) {
        segments.add(_HeadSeg(line.substring(4), 3));
      } else if (line.startsWith('## ')) {
        segments.add(_HeadSeg(line.substring(3), 2));
      } else if (line.startsWith('# ')) {
        segments.add(_HeadSeg(line.substring(2), 1));
      } else if (line.startsWith('- ') || line.startsWith('• ')) {
        segments.add(_BulletSeg(line.substring(2)));
      } else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        final dotIdx = line.indexOf('. ');
        final num = line.substring(0, dotIdx);
        final content = line.substring(dotIdx + 2);
        segments.add(_NumSeg(num, content));
      } else if (line.isEmpty) {
        segments.add(_SpaceSeg());
      } else {
        segments.add(_TextSeg(line));
      }
    }
    return segments;
  }
}

abstract class _Seg {
  Widget build(BuildContext context);
}

class _SpaceSeg extends _Seg {
  @override Widget build(BuildContext _) => const SizedBox(height: 6);
}

class _HeadSeg extends _Seg {
  final String text;
  final int level;
  _HeadSeg(this.text, this.level);
  @override Widget build(BuildContext _) {
    final size = level == 1 ? 17.0 : level == 2 ? 15.0 : 13.0;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 3),
      child: Text(_inlineStyle(text),
          style: TextStyle(color: AppColors.accent,
              fontSize: size, fontWeight: FontWeight.w800)),
    );
  }
}

class _BulletSeg extends _Seg {
  final String text;
  _BulletSeg(this.text);
  @override Widget build(BuildContext _) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('  • ', style: TextStyle(color: AppColors.accent,
          fontWeight: FontWeight.w800, fontSize: 14)),
      Expanded(child: Text(_inlineStyle(text),
          style: const TextStyle(color: AppColors.textPrimary,
              fontSize: 13, height: 1.5))),
    ]),
  );
}

class _NumSeg extends _Seg {
  final String num, text;
  _NumSeg(this.num, this.text);
  @override Widget build(BuildContext _) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        margin: const EdgeInsets.only(top: 1, right: 8),
        width: 22, height: 22,
        decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            shape: BoxShape.circle),
        child: Center(child: Text(num,
            style: const TextStyle(color: AppColors.accent,
                fontSize: 11, fontWeight: FontWeight.w800))),
      ),
      Expanded(child: Text(_inlineStyle(text),
          style: const TextStyle(color: AppColors.textPrimary,
              fontSize: 13, height: 1.5))),
    ]),
  );
}

class _TextSeg extends _Seg {
  final String text;
  _TextSeg(this.text);
  @override Widget build(BuildContext _) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Text(_inlineStyle(text),
        style: const TextStyle(color: AppColors.textPrimary,
            fontSize: 13, height: 1.55)),
  );
}

class _CodeSeg extends _Seg {
  final String code, lang;
  _CodeSeg(this.code, this.lang);
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF0D1F3C),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.accent.withOpacity(0.2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(lang.isEmpty ? 'code' : lang,
              style: const TextStyle(color: AppColors.accent,
                  fontSize: 11, fontWeight: FontWeight.w700)),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code copied!'),
                    duration: Duration(seconds: 1)));
            },
            child: const Row(children: [
              Icon(Icons.copy_rounded, color: AppColors.textSecondary, size: 13),
              SizedBox(width: 4),
              Text('Copy', style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
            ]),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(code,
              style: const TextStyle(
                  color: Color(0xFF7DD3FC),
                  fontFamily: 'monospace',
                  fontSize: 12, height: 1.6)),
        ),
      ),
    ]),
  );
}

// Simple inline bold/italic stripper (converts **text** → bold)
String _inlineStyle(String text) {
  // Strip markdown bold/italic markers for plain text display
  return text
      .replaceAll('**', '')
      .replaceAll('__', '')
      .replaceAll('*', '')
      .replaceAll('_', '');
}

// ─────────────────────────────────────────────────────────────
// Pending Image Preview
// ─────────────────────────────────────────────────────────────
class _ImagePreview extends StatelessWidget {
  final Uint8List bytes;
  final VoidCallback onRemove;
  const _ImagePreview({required this.bytes, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(bytes,
                width: 90, height: 90, fit: BoxFit.cover),
          ),
          Positioned(
            top: -6, right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22, height: 22,
                decoration: const BoxDecoration(
                    color: AppColors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Input Bar
// ─────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool loading, hasImage;
  final VoidCallback onPickImage;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.loading,
    required this.hasImage,
    required this.onPickImage,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        // Image attach
        GestureDetector(
          onTap: loading ? null : onPickImage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: hasImage
                  ? AppColors.accent.withOpacity(0.15)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(13),
              border: hasImage
                  ? Border.all(color: AppColors.accent.withOpacity(0.5))
                  : null,
            ),
            child: Icon(
              hasImage ? Icons.image_rounded : Icons.add_photo_alternate_rounded,
              color: hasImage ? AppColors.accent : AppColors.textSecondary,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Text field
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 120),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: null,
              enabled: !loading,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Ask me anything...',
                hintStyle: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 11),
                filled: false,
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Send button
        GestureDetector(
          onTap: loading ? null : onSend,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42, height: 42,
            decoration: BoxDecoration(
              gradient: loading
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF00D9A3), Color(0xFF3B82F6)],
                    ),
              color: loading ? AppColors.card : null,
              borderRadius: BorderRadius.circular(13),
              boxShadow: loading
                  ? null
                  : [BoxShadow(
                      color: AppColors.accent.withOpacity(0.35),
                      blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: loading
                ? const Center(
                    child: SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.accent),
                      ),
                    ),
                  )
                : const Icon(Icons.send_rounded,
                    color: AppColors.bg, size: 20),
          ),
        ),
      ]),
    );
  }
}