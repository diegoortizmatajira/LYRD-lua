return {
	msbuild = {
		enabled = true,
		-- ToolsVersion = nil,
		-- VisualStudioVersion = nil,
		-- Configuration = nil,
		-- Platform = nil,
		EnablePackageAutoRestore = true,
		-- MSBuildExtensionsPath = nil,
		-- TargetFrameworkRootPath = nil,
		-- MSBuildSDKsPath = nil,
		-- RoslynTargetsPath = nil,
		-- CscToolPath = nil,
		-- CscToolExe = nil,
		loadProjectsOnDemand = false,
		-- GenerateBinaryLogs = false,
	},
	Sdk = {
		IncludePrereleases = true,
	},
	cake = {
		enabled = true,
		bakeryPath = nil,
	},
	FormattingOptions = {
		EnableEditorConfigSupport = true,
		OrganizeImports = true,
		-- NewLine = "\n",
		-- UseTabs = false,
		-- TabSize = 4,
		-- IndentationSize = 4,
		-- SpacingAfterMethodDeclarationName = false,
		-- SpaceWithinMethodDeclarationParenthesis = false,
		-- SpaceBetweenEmptyMethodDeclarationParentheses = false,
		-- SpaceAfterMethodCallName = false,
		-- SpaceWithinMethodCallParentheses = false,
		-- SpaceBetweenEmptyMethodCallParentheses = false,
		-- SpaceAfterControlFlowStatementKeyword = true,
		-- SpaceWithinExpressionParentheses = false,
		-- SpaceWithinCastParentheses = false,
		-- SpaceWithinOtherParentheses = false,
		-- SpaceAfterCast = false,
		-- SpacesIgnoreAroundVariableDeclaration = false,
		-- SpaceBeforeOpenSquareBracket = false,
		-- SpaceBetweenEmptySquareBrackets = false,
		-- SpaceWithinSquareBrackets = false,
		-- SpaceAfterColonInBaseTypeDeclaration = true,
		-- SpaceAfterComma = true,
		-- SpaceAfterDot = false,
		-- SpaceAfterSemicolonsInForStatement = true,
		-- SpaceBeforeColonInBaseTypeDeclaration = true,
		-- SpaceBeforeComma = false,
		-- SpaceBeforeDot = false,
		-- SpaceBeforeSemicolonsInForStatement = false,
		-- SpacingAroundBinaryOperator = "single",
		-- IndentBraces = false,
		-- IndentBlock = true,
		-- IndentSwitchSection = true,
		-- IndentSwitchCaseSection = true,
		-- IndentSwitchCaseSectionWhenBlock = true,
		-- LabelPositioning = "oneLess",
		-- WrappingPreserveSingleLine = true,
		-- WrappingKeepStatementsOnSingleLine = true,
		-- NewLinesForBracesInTypes = true,
		-- NewLinesForBracesInMethods = true,
		-- NewLinesForBracesInProperties = true,
		-- NewLinesForBracesInAccessors = true,
		-- NewLinesForBracesInAnonymousMethods = true,
		-- NewLinesForBracesInControlBlocks = true,
		-- NewLinesForBracesInAnonymousTypes = true,
		-- NewLinesForBracesInObjectCollectionArrayInitializers = true,
		-- NewLinesForBracesInLambdaExpressionBody = true,
		-- NewLineForElse = true,
		-- NewLineForCatch = true,
		-- NewLineForFinally = true,
		-- NewLineForMembersInObjectInit = true,
		-- NewLineForMembersInAnonymousTypes = true,
		-- NewLineForClausesInQuery = true,
	},
	RoslynExtensionsOptions = {
		AnalyzeOpenDocumentsOnly = false,
		-- documentAnalysisTimeoutMs = 30000,
		enableDecompilationSupport = true,
		enableImportCompletion = true,
		enableAnalyzersSupport = false,
		-- diagnosticWorkersThreadCount = 8,
		-- locationPaths = {
		-- 	"//path_to/code_actions.dll",
		-- },
		-- inlayHintsOptions = {
		-- 	enableForParameters = true,
		-- 	forLiteralParameters = true,
		-- 	forIndexerParameters = true,
		-- 	forObjectCreationParameters = true,
		-- 	forOtherParameters = true,
		-- 	suppressForParametersThatDifferOnlyBySuffix = false,
		-- 	suppressForParametersThatMatchMethodIntent = false,
		-- 	suppressForParametersThatMatchArgumentName = false,
		-- 	enableForTypes = true,
		-- 	forImplicitVariableTypes = true,
		-- 	forLambdaParameterTypes = true,
		-- 	forImplicitObjectCreation = true,
		-- },
	},
	-- fileOptions = {
	-- 	systemExcludeSearchPatterns = {
	-- 		"**/node_modules/**/*",
	-- 		"**/bin/**/*",
	-- 		"**/obj/**/*",
	-- 	},
	-- 	excludeSearchPatterns = {},
	-- },
	-- RenameOptions = {
	-- 	RenameInComments = false,
	-- 	RenameOverloads = false,
	-- 	RenameInStrings = false,
	-- },
}
