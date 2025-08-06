# Flutter 3D Project Makefile
# このMakefileは開発フローをサポートします

.PHONY: help install analyze test fix clean build ci-check

# デフォルトターゲット
help:
	@echo "Available commands:"
	@echo "  install     - 依存関係をインストール"
	@echo "  analyze     - 静的解析を実行"
	@echo "  test        - テストを実行"
	@echo "  test-cov    - カバレッジ付きテストを実行"
	@echo "  fix         - 自動修正可能な問題を修正"
	@echo "  clean       - クリーンアップ"
	@echo "  build       - アプリケーションをビルド"
	@echo "  ci-check    - CI/CD品質チェックを実行"

# 依存関係のインストール
install:
	flutter pub get
	dart run build_runner build --delete-conflicting-outputs

# 静的解析
analyze:
	dart format --output=none --set-exit-if-changed .
	flutter analyze --fatal-infos
	dart run dart_code_linter:metrics analyze lib

# テスト実行
test:
	flutter test test/features/maze_ball/

# カバレッジ付きテスト
test-cov:
	flutter test test/features/maze_ball/ --coverage
	@echo "カバレッジレポート: coverage/lcov.info"

# 自動修正
fix:
	dart fix --apply
	dart format .

# クリーンアップ
clean:
	flutter clean
	rm -rf coverage/
	rm -rf .dart_tool/

# ビルド
build:
	flutter build apk --debug
	flutter build web

# CI/CD品質チェック（実際のCI環境と同等）
ci-check:
	@echo "🔍 CI/CD品質チェックを開始..."
	@echo "📦 依存関係のインストール..."
	flutter pub get
	dart run build_runner build --delete-conflicting-outputs
	@echo "📝 フォーマットチェック..."
	dart format --output=none --set-exit-if-changed .
	@echo "🧹 静的解析..."
	flutter analyze --fatal-infos
	@echo "📈 コード品質メトリクス..."
	dart run dart_code_linter:metrics analyze lib
	@echo "🧪 テスト実行..."
	flutter test test/features/maze_ball/ --coverage
	@echo "✅ 全てのチェックが完了しました！"