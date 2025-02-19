// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This code was auto-generated, is not intended to be edited, and is subject to
// significant change. Please see the README file for more information.

library engine.parser;

import 'dart:collection';
import "dart:math" as math;

import 'ast.dart';
import 'engine.dart' show AnalysisEngine, AnalysisOptionsImpl;
import 'error.dart';
import 'java_core.dart';
import 'java_engine.dart';
import 'scanner.dart';
import 'source.dart';
import 'utilities_collection.dart' show TokenMap;
import 'utilities_dart.dart';

Map<String, MethodTrampoline> methodTable_Parser = <String, MethodTrampoline>{
  'parseCompilationUnit_1': new MethodTrampoline(
      1, (Parser target, arg0) => target.parseCompilationUnit(arg0)),
  'parseDirectives_1': new MethodTrampoline(
      1, (Parser target, arg0) => target.parseDirectives(arg0)),
  'parseExpression_1': new MethodTrampoline(
      1, (Parser target, arg0) => target.parseExpression(arg0)),
  'parseStatement_1': new MethodTrampoline(
      1, (Parser target, arg0) => target.parseStatement(arg0)),
  'parseStatements_1': new MethodTrampoline(
      1, (Parser target, arg0) => target.parseStatements(arg0)),
  'parseAnnotation_0':
      new MethodTrampoline(0, (Parser target) => target.parseAnnotation()),
  'parseArgument_0':
      new MethodTrampoline(0, (Parser target) => target.parseArgument()),
  'parseArgumentList_0':
      new MethodTrampoline(0, (Parser target) => target.parseArgumentList()),
  'parseBitwiseOrExpression_0': new MethodTrampoline(
      0, (Parser target) => target.parseBitwiseOrExpression()),
  'parseBlock_0':
      new MethodTrampoline(0, (Parser target) => target.parseBlock()),
  'parseClassMember_1': new MethodTrampoline(
      1, (Parser target, arg0) => target.parseClassMember(arg0)),
  'parseCompilationUnit_0': new MethodTrampoline(
      0, (Parser target) => target.parseCompilationUnit2()),
  'parseConditionalExpression_0': new MethodTrampoline(
      0, (Parser target) => target.parseConditionalExpression()),
  'parseConstructorName_0':
      new MethodTrampoline(0, (Parser target) => target.parseConstructorName()),
  'parseExpression_0':
      new MethodTrampoline(0, (Parser target) => target.parseExpression2()),
  'parseExpressionWithoutCascade_0': new MethodTrampoline(
      0, (Parser target) => target.parseExpressionWithoutCascade()),
  'parseExtendsClause_0':
      new MethodTrampoline(0, (Parser target) => target.parseExtendsClause()),
  'parseFormalParameterList_0': new MethodTrampoline(
      0, (Parser target) => target.parseFormalParameterList()),
  'parseFunctionExpression_0': new MethodTrampoline(
      0, (Parser target) => target.parseFunctionExpression()),
  'parseImplementsClause_0': new MethodTrampoline(
      0, (Parser target) => target.parseImplementsClause()),
  'parseLabel_0':
      new MethodTrampoline(0, (Parser target) => target.parseLabel()),
  'parseLibraryIdentifier_0': new MethodTrampoline(
      0, (Parser target) => target.parseLibraryIdentifier()),
  'parseLogicalOrExpression_0': new MethodTrampoline(
      0, (Parser target) => target.parseLogicalOrExpression()),
  'parseMapLiteralEntry_0':
      new MethodTrampoline(0, (Parser target) => target.parseMapLiteralEntry()),
  'parseNormalFormalParameter_0': new MethodTrampoline(
      0, (Parser target) => target.parseNormalFormalParameter()),
  'parsePrefixedIdentifier_0': new MethodTrampoline(
      0, (Parser target) => target.parsePrefixedIdentifier()),
  'parseReturnType_0':
      new MethodTrampoline(0, (Parser target) => target.parseReturnType()),
  'parseSimpleIdentifier_0': new MethodTrampoline(
      0, (Parser target) => target.parseSimpleIdentifier()),
  'parseStatement_0':
      new MethodTrampoline(0, (Parser target) => target.parseStatement2()),
  'parseStringLiteral_0':
      new MethodTrampoline(0, (Parser target) => target.parseStringLiteral()),
  'parseTypeArgumentList_0': new MethodTrampoline(
      0, (Parser target) => target.parseTypeArgumentList()),
  'parseTypeName_0':
      new MethodTrampoline(0, (Parser target) => target.parseTypeName()),
  'parseTypeParameter_0':
      new MethodTrampoline(0, (Parser target) => target.parseTypeParameter()),
  'parseTypeParameterList_0': new MethodTrampoline(
      0, (Parser target) => target.parseTypeParameterList()),
  'parseWithClause_0':
      new MethodTrampoline(0, (Parser target) => target.parseWithClause()),
  'advance_0': new MethodTrampoline(0, (Parser target) => target._advance()),
  'appendScalarValue_5': new MethodTrampoline(5, (Parser target, arg0, arg1,
      arg2, arg3,
      arg4) => target._appendScalarValue(arg0, arg1, arg2, arg3, arg4)),
  'computeStringValue_3': new MethodTrampoline(3, (Parser target, arg0, arg1,
      arg2) => target._computeStringValue(arg0, arg1, arg2)),
  'convertToFunctionDeclaration_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._convertToFunctionDeclaration(arg0)),
  'couldBeStartOfCompilationUnitMember_0': new MethodTrampoline(
      0, (Parser target) => target._couldBeStartOfCompilationUnitMember()),
  'createSyntheticIdentifier_0': new MethodTrampoline(
      0, (Parser target) => target._createSyntheticIdentifier()),
  'createSyntheticKeyword_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._createSyntheticKeyword(arg0)),
  'createSyntheticStringLiteral_0': new MethodTrampoline(
      0, (Parser target) => target._createSyntheticStringLiteral()),
  'createSyntheticToken_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._createSyntheticToken(arg0)),
  'ensureAssignable_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._ensureAssignable(arg0)),
  'expect_1':
      new MethodTrampoline(1, (Parser target, arg0) => target._expect(arg0)),
  'expectGt_0': new MethodTrampoline(0, (Parser target) => target._expectGt()),
  'expectKeyword_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._expectKeyword(arg0)),
  'expectSemicolon_0':
      new MethodTrampoline(0, (Parser target) => target._expectSemicolon()),
  'findRange_2': new MethodTrampoline(
      2, (Parser target, arg0, arg1) => target._findRange(arg0, arg1)),
  'getCodeBlockRanges_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._getCodeBlockRanges(arg0)),
  'getEndToken_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._getEndToken(arg0)),
  'injectToken_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._injectToken(arg0)),
  'isFunctionDeclaration_0': new MethodTrampoline(
      0, (Parser target) => target._isFunctionDeclaration()),
  'isFunctionExpression_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._isFunctionExpression(arg0)),
  'isHexDigit_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._isHexDigit(arg0)),
  'isInitializedVariableDeclaration_0': new MethodTrampoline(
      0, (Parser target) => target._isInitializedVariableDeclaration()),
  'isLinkText_2': new MethodTrampoline(
      2, (Parser target, arg0, arg1) => target._isLinkText(arg0, arg1)),
  'isOperator_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._isOperator(arg0)),
  'isSwitchMember_0':
      new MethodTrampoline(0, (Parser target) => target._isSwitchMember()),
  'isTypedIdentifier_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._isTypedIdentifier(arg0)),
  'lockErrorListener_0':
      new MethodTrampoline(0, (Parser target) => target._lockErrorListener()),
  'matches_1':
      new MethodTrampoline(1, (Parser target, arg0) => target._matches(arg0)),
  'matchesGt_0':
      new MethodTrampoline(0, (Parser target) => target._matchesGt()),
  'matchesIdentifier_0':
      new MethodTrampoline(0, (Parser target) => target._matchesIdentifier()),
  'matchesKeyword_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._matchesKeyword(arg0)),
  'matchesString_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._matchesString(arg0)),
  'optional_1':
      new MethodTrampoline(1, (Parser target, arg0) => target._optional(arg0)),
  'parseAdditiveExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseAdditiveExpression()),
  'parseAssertStatement_0': new MethodTrampoline(
      0, (Parser target) => target._parseAssertStatement()),
  'parseAssignableExpression_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseAssignableExpression(arg0)),
  'parseAssignableSelector_2': new MethodTrampoline(2, (Parser target, arg0,
      arg1) => target._parseAssignableSelector(arg0, arg1)),
  'parseAwaitExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseAwaitExpression()),
  'parseBitwiseAndExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseBitwiseAndExpression()),
  'parseBitwiseXorExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseBitwiseXorExpression()),
  'parseBreakStatement_0':
      new MethodTrampoline(0, (Parser target) => target._parseBreakStatement()),
  'parseCascadeSection_0':
      new MethodTrampoline(0, (Parser target) => target._parseCascadeSection()),
  'parseClassDeclaration_2': new MethodTrampoline(2,
      (Parser target, arg0, arg1) => target._parseClassDeclaration(arg0, arg1)),
  'parseClassMembers_2': new MethodTrampoline(
      2, (Parser target, arg0, arg1) => target._parseClassMembers(arg0, arg1)),
  'parseClassTypeAlias_3': new MethodTrampoline(3, (Parser target, arg0, arg1,
      arg2) => target._parseClassTypeAlias(arg0, arg1, arg2)),
  'parseCombinator_0':
      new MethodTrampoline(0, (Parser target) => target.parseCombinator()),
  'parseCombinators_0':
      new MethodTrampoline(0, (Parser target) => target._parseCombinators()),
  'parseCommentAndMetadata_0': new MethodTrampoline(
      0, (Parser target) => target._parseCommentAndMetadata()),
  'parseCommentReference_2': new MethodTrampoline(2,
      (Parser target, arg0, arg1) => target._parseCommentReference(arg0, arg1)),
  'parseCommentReferences_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseCommentReferences(arg0)),
  'parseCompilationUnitMember_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseCompilationUnitMember(arg0)),
  'parseConstExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseConstExpression()),
  'parseConstructor_8': new MethodTrampoline(8, (Parser target, arg0, arg1,
          arg2, arg3, arg4, arg5, arg6, arg7) =>
      target._parseConstructor(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)),
  'parseConstructorFieldInitializer_0': new MethodTrampoline(
      0, (Parser target) => target._parseConstructorFieldInitializer()),
  'parseContinueStatement_0': new MethodTrampoline(
      0, (Parser target) => target._parseContinueStatement()),
  'parseDirective_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseDirective(arg0)),
  'parseDirectives_0':
      new MethodTrampoline(0, (Parser target) => target._parseDirectives()),
  'parseDocumentationComment_0': new MethodTrampoline(
      0, (Parser target) => target._parseDocumentationComment()),
  'parseDoStatement_0':
      new MethodTrampoline(0, (Parser target) => target._parseDoStatement()),
  'parseEmptyStatement_0':
      new MethodTrampoline(0, (Parser target) => target._parseEmptyStatement()),
  'parseEnumConstantDeclaration_0': new MethodTrampoline(
      0, (Parser target) => target._parseEnumConstantDeclaration()),
  'parseEnumDeclaration_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseEnumDeclaration(arg0)),
  'parseEqualityExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseEqualityExpression()),
  'parseExportDirective_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseExportDirective(arg0)),
  'parseExpressionList_0':
      new MethodTrampoline(0, (Parser target) => target._parseExpressionList()),
  'parseFinalConstVarOrType_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseFinalConstVarOrType(arg0)),
  'parseFormalParameter_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseFormalParameter(arg0)),
  'parseForStatement_0':
      new MethodTrampoline(0, (Parser target) => target._parseForStatement()),
  'parseFunctionBody_3': new MethodTrampoline(3, (Parser target, arg0, arg1,
      arg2) => target._parseFunctionBody(arg0, arg1, arg2)),
  'parseFunctionDeclaration_3': new MethodTrampoline(3, (Parser target, arg0,
      arg1, arg2) => target._parseFunctionDeclaration(arg0, arg1, arg2)),
  'parseFunctionDeclarationStatement_0': new MethodTrampoline(
      0, (Parser target) => target._parseFunctionDeclarationStatement()),
  'parseFunctionDeclarationStatementAfterReturnType_2': new MethodTrampoline(2,
      (Parser target, arg0, arg1) =>
          target._parseFunctionDeclarationStatementAfterReturnType(arg0, arg1)),
  'parseFunctionTypeAlias_2': new MethodTrampoline(2, (Parser target, arg0,
      arg1) => target._parseFunctionTypeAlias(arg0, arg1)),
  'parseGetter_4': new MethodTrampoline(4, (Parser target, arg0, arg1, arg2,
      arg3) => target._parseGetter(arg0, arg1, arg2, arg3)),
  'parseIdentifierList_0':
      new MethodTrampoline(0, (Parser target) => target._parseIdentifierList()),
  'parseIfStatement_0':
      new MethodTrampoline(0, (Parser target) => target._parseIfStatement()),
  'parseImportDirective_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseImportDirective(arg0)),
  'parseInitializedIdentifierList_4': new MethodTrampoline(4,
      (Parser target, arg0, arg1, arg2, arg3) =>
          target._parseInitializedIdentifierList(arg0, arg1, arg2, arg3)),
  'parseInstanceCreationExpression_1': new MethodTrampoline(1,
      (Parser target, arg0) => target._parseInstanceCreationExpression(arg0)),
  'parseLibraryDirective_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseLibraryDirective(arg0)),
  'parseLibraryName_2': new MethodTrampoline(
      2, (Parser target, arg0, arg1) => target._parseLibraryName(arg0, arg1)),
  'parseListLiteral_2': new MethodTrampoline(
      2, (Parser target, arg0, arg1) => target._parseListLiteral(arg0, arg1)),
  'parseListOrMapLiteral_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseListOrMapLiteral(arg0)),
  'parseLogicalAndExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseLogicalAndExpression()),
  'parseMapLiteral_2': new MethodTrampoline(
      2, (Parser target, arg0, arg1) => target._parseMapLiteral(arg0, arg1)),
  'parseMethodDeclarationAfterParameters_7': new MethodTrampoline(7,
      (Parser target, arg0, arg1, arg2, arg3, arg4, arg5, arg6) => target
          ._parseMethodDeclarationAfterParameters(
              arg0, arg1, arg2, arg3, arg4, arg5, arg6)),
  'parseMethodDeclarationAfterReturnType_4': new MethodTrampoline(4,
      (Parser target, arg0, arg1, arg2, arg3) => target
          ._parseMethodDeclarationAfterReturnType(arg0, arg1, arg2, arg3)),
  'parseModifiers_0':
      new MethodTrampoline(0, (Parser target) => target._parseModifiers()),
  'parseMultiplicativeExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseMultiplicativeExpression()),
  'parseNativeClause_0':
      new MethodTrampoline(0, (Parser target) => target._parseNativeClause()),
  'parseNewExpression_0':
      new MethodTrampoline(0, (Parser target) => target._parseNewExpression()),
  'parseNonLabeledStatement_0': new MethodTrampoline(
      0, (Parser target) => target._parseNonLabeledStatement()),
  'parseOperator_3': new MethodTrampoline(3, (Parser target, arg0, arg1,
      arg2) => target._parseOperator(arg0, arg1, arg2)),
  'parseOptionalReturnType_0': new MethodTrampoline(
      0, (Parser target) => target._parseOptionalReturnType()),
  'parsePartDirective_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parsePartDirective(arg0)),
  'parsePostfixExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parsePostfixExpression()),
  'parsePrimaryExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parsePrimaryExpression()),
  'parseRedirectingConstructorInvocation_0': new MethodTrampoline(
      0, (Parser target) => target._parseRedirectingConstructorInvocation()),
  'parseRelationalExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseRelationalExpression()),
  'parseRethrowExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseRethrowExpression()),
  'parseReturnStatement_0': new MethodTrampoline(
      0, (Parser target) => target._parseReturnStatement()),
  'parseSetter_4': new MethodTrampoline(4, (Parser target, arg0, arg1, arg2,
      arg3) => target._parseSetter(arg0, arg1, arg2, arg3)),
  'parseShiftExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseShiftExpression()),
  'parseStatementList_0':
      new MethodTrampoline(0, (Parser target) => target._parseStatementList()),
  'parseStringInterpolation_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseStringInterpolation(arg0)),
  'parseSuperConstructorInvocation_0': new MethodTrampoline(
      0, (Parser target) => target._parseSuperConstructorInvocation()),
  'parseSwitchStatement_0': new MethodTrampoline(
      0, (Parser target) => target._parseSwitchStatement()),
  'parseSymbolLiteral_0':
      new MethodTrampoline(0, (Parser target) => target._parseSymbolLiteral()),
  'parseThrowExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseThrowExpression()),
  'parseThrowExpressionWithoutCascade_0': new MethodTrampoline(
      0, (Parser target) => target._parseThrowExpressionWithoutCascade()),
  'parseTryStatement_0':
      new MethodTrampoline(0, (Parser target) => target._parseTryStatement()),
  'parseTypeAlias_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._parseTypeAlias(arg0)),
  'parseUnaryExpression_0': new MethodTrampoline(
      0, (Parser target) => target._parseUnaryExpression()),
  'parseVariableDeclaration_0': new MethodTrampoline(
      0, (Parser target) => target._parseVariableDeclaration()),
  'parseVariableDeclarationListAfterMetadata_1': new MethodTrampoline(1,
      (Parser target, arg0) =>
          target._parseVariableDeclarationListAfterMetadata(arg0)),
  'parseVariableDeclarationListAfterType_3': new MethodTrampoline(3,
      (Parser target, arg0, arg1, arg2) =>
          target._parseVariableDeclarationListAfterType(arg0, arg1, arg2)),
  'parseVariableDeclarationStatementAfterMetadata_1': new MethodTrampoline(1,
      (Parser target, arg0) =>
          target._parseVariableDeclarationStatementAfterMetadata(arg0)),
  'parseVariableDeclarationStatementAfterType_3': new MethodTrampoline(3,
      (Parser target, arg0, arg1, arg2) =>
          target._parseVariableDeclarationStatementAfterType(arg0, arg1, arg2)),
  'parseWhileStatement_0':
      new MethodTrampoline(0, (Parser target) => target._parseWhileStatement()),
  'parseYieldStatement_0':
      new MethodTrampoline(0, (Parser target) => target._parseYieldStatement()),
  'peek_0': new MethodTrampoline(0, (Parser target) => target._peek()),
  'peekAt_1':
      new MethodTrampoline(1, (Parser target, arg0) => target._peekAt(arg0)),
  'reportError_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._reportError(arg0)),
  'reportErrorForCurrentToken_2': new MethodTrampoline(2, (Parser target, arg0,
      arg1) => target._reportErrorForCurrentToken(arg0, arg1)),
  'reportErrorForNode_3': new MethodTrampoline(3, (Parser target, arg0, arg1,
      arg2) => target._reportErrorForNode(arg0, arg1, arg2)),
  'reportErrorForToken_3': new MethodTrampoline(3, (Parser target, arg0, arg1,
      arg2) => target._reportErrorForToken(arg0, arg1, arg2)),
  'skipBlock_0':
      new MethodTrampoline(0, (Parser target) => target._skipBlock()),
  'skipFinalConstVarOrType_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._skipFinalConstVarOrType(arg0)),
  'skipFormalParameterList_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._skipFormalParameterList(arg0)),
  'skipPastMatchingToken_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._skipPastMatchingToken(arg0)),
  'skipPrefixedIdentifier_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._skipPrefixedIdentifier(arg0)),
  'skipReturnType_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._skipReturnType(arg0)),
  'skipSimpleIdentifier_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._skipSimpleIdentifier(arg0)),
  'skipStringInterpolation_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._skipStringInterpolation(arg0)),
  'skipStringLiteral_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._skipStringLiteral(arg0)),
  'skipTypeArgumentList_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._skipTypeArgumentList(arg0)),
  'skipTypeName_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._skipTypeName(arg0)),
  'skipTypeParameterList_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._skipTypeParameterList(arg0)),
  'tokenMatches_2': new MethodTrampoline(
      2, (Parser target, arg0, arg1) => target._tokenMatches(arg0, arg1)),
  'tokenMatchesIdentifier_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._tokenMatchesIdentifier(arg0)),
  'tokenMatchesKeyword_2': new MethodTrampoline(2,
      (Parser target, arg0, arg1) => target._tokenMatchesKeyword(arg0, arg1)),
  'tokenMatchesString_2': new MethodTrampoline(
      2, (Parser target, arg0, arg1) => target._tokenMatchesString(arg0, arg1)),
  'translateCharacter_3': new MethodTrampoline(3, (Parser target, arg0, arg1,
      arg2) => target._translateCharacter(arg0, arg1, arg2)),
  'unlockErrorListener_0':
      new MethodTrampoline(0, (Parser target) => target._unlockErrorListener()),
  'validateFormalParameterList_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._validateFormalParameterList(arg0)),
  'validateModifiersForClass_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._validateModifiersForClass(arg0)),
  'validateModifiersForConstructor_1': new MethodTrampoline(1,
      (Parser target, arg0) => target._validateModifiersForConstructor(arg0)),
  'validateModifiersForEnum_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._validateModifiersForEnum(arg0)),
  'validateModifiersForField_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._validateModifiersForField(arg0)),
  'validateModifiersForFunctionDeclarationStatement_1': new MethodTrampoline(1,
      (Parser target, arg0) =>
          target._validateModifiersForFunctionDeclarationStatement(arg0)),
  'validateModifiersForGetterOrSetterOrMethod_1': new MethodTrampoline(1,
      (Parser target, arg0) =>
          target._validateModifiersForGetterOrSetterOrMethod(arg0)),
  'validateModifiersForOperator_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._validateModifiersForOperator(arg0)),
  'validateModifiersForTopLevelDeclaration_1': new MethodTrampoline(1,
      (Parser target, arg0) =>
          target._validateModifiersForTopLevelDeclaration(arg0)),
  'validateModifiersForTopLevelFunction_1': new MethodTrampoline(1,
      (Parser target, arg0) =>
          target._validateModifiersForTopLevelFunction(arg0)),
  'validateModifiersForTopLevelVariable_1': new MethodTrampoline(1,
      (Parser target, arg0) =>
          target._validateModifiersForTopLevelVariable(arg0)),
  'validateModifiersForTypedef_1': new MethodTrampoline(
      1, (Parser target, arg0) => target._validateModifiersForTypedef(arg0)),
};

Object invokeParserMethodImpl(
    Parser parser, String methodName, List<Object> objects, Token tokenStream) {
  parser.currentToken = tokenStream;
  MethodTrampoline method =
      methodTable_Parser['${methodName}_${objects.length}'];
  if (method == null) {
    throw new IllegalArgumentException('There is no method named $methodName');
  }
  return method.invoke(parser, objects);
}

/**
 * A simple data-holder for a method that needs to return multiple values.
 */
class CommentAndMetadata {
  /**
   * The documentation comment that was parsed, or `null` if none was given.
   */
  final Comment comment;

  /**
   * The metadata that was parsed.
   */
  final List<Annotation> metadata;

  /**
   * Initialize a newly created holder with the given [comment] and [metadata].
   */
  CommentAndMetadata(this.comment, this.metadata);
}

/**
 * A simple data-holder for a method that needs to return multiple values.
 */
class FinalConstVarOrType {
  /**
   * The 'final', 'const' or 'var' keyword, or `null` if none was given.
   */
  final Token keyword;

  /**
   * The type, of `null` if no type was specified.
   */
  final TypeName type;

  /**
   * Initialize a newly created holder with the given [keyword] and [type].
   */
  FinalConstVarOrType(this.keyword, this.type);
}

/**
 * A dispatcher that will invoke the right parse method when re-parsing a
 * specified child of the visited node. All of the methods in this class assume
 * that the parser is positioned to parse the replacement for the node. All of
 * the methods will throw an [IncrementalParseException] if the node could not
 * be parsed for some reason.
 */
class IncrementalParseDispatcher implements AstVisitor<AstNode> {
  /**
   * The parser used to parse the replacement for the node.
   */
  final Parser _parser;

  /**
   * The node that is to be replaced.
   */
  final AstNode _oldNode;

  /**
   * Initialize a newly created dispatcher to parse a single node that will
   * use the [_parser] to replace the [_oldNode].
   */
  IncrementalParseDispatcher(this._parser, this._oldNode);

  @override
  AstNode visitAdjacentStrings(AdjacentStrings node) {
    if (node.strings.contains(_oldNode)) {
      return _parser.parseStringLiteral();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitAnnotation(Annotation node) {
    if (identical(_oldNode, node.name)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.constructorName)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.arguments)) {
      return _parser.parseArgumentList();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitArgumentList(ArgumentList node) {
    if (node.arguments.contains(_oldNode)) {
      return _parser.parseArgument();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitAsExpression(AsExpression node) {
    if (identical(_oldNode, node.expression)) {
      return _parser.parseBitwiseOrExpression();
    } else if (identical(_oldNode, node.type)) {
      return _parser.parseTypeName();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitAssertStatement(AssertStatement node) {
    if (identical(_oldNode, node.condition)) {
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitAssignmentExpression(AssignmentExpression node) {
    if (identical(_oldNode, node.leftHandSide)) {
      // TODO(brianwilkerson) If the assignment is part of a cascade section,
      // then we don't have a single parse method that will work.
      // Otherwise, we can parse a conditional expression, but need to ensure
      // that the resulting expression is assignable.
//      return parser.parseConditionalExpression();
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.rightHandSide)) {
      if (_isCascadeAllowedInAssignment(node)) {
        return _parser.parseExpression2();
      }
      return _parser.parseExpressionWithoutCascade();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitAwaitExpression(AwaitExpression node) {
    if (identical(_oldNode, node.expression)) {
      // TODO(brianwilkerson) Depending on precedence,
      // this might not be sufficient.
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitBinaryExpression(BinaryExpression node) {
    if (identical(_oldNode, node.leftOperand)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.rightOperand)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitBlock(Block node) {
    if (node.statements.contains(_oldNode)) {
      return _parser.parseStatement2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitBlockFunctionBody(BlockFunctionBody node) {
    if (identical(_oldNode, node.block)) {
      return _parser.parseBlock();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitBooleanLiteral(BooleanLiteral node) => _notAChild(node);

  @override
  AstNode visitBreakStatement(BreakStatement node) {
    if (identical(_oldNode, node.label)) {
      return _parser.parseSimpleIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitCascadeExpression(CascadeExpression node) {
    if (identical(_oldNode, node.target)) {
      return _parser.parseConditionalExpression();
    } else if (node.cascadeSections.contains(_oldNode)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitCatchClause(CatchClause node) {
    if (identical(_oldNode, node.exceptionType)) {
      return _parser.parseTypeName();
    } else if (identical(_oldNode, node.exceptionParameter)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.stackTraceParameter)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.body)) {
      return _parser.parseBlock();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitClassDeclaration(ClassDeclaration node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.name)) {
      // Changing the class name changes whether a member is interpreted as a
      // constructor or not, so we'll just have to re-parse the entire class.
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.typeParameters)) {
      return _parser.parseTypeParameterList();
    } else if (identical(_oldNode, node.extendsClause)) {
      return _parser.parseExtendsClause();
    } else if (identical(_oldNode, node.withClause)) {
      return _parser.parseWithClause();
    } else if (identical(_oldNode, node.implementsClause)) {
      return _parser.parseImplementsClause();
    } else if (node.members.contains(_oldNode)) {
      ClassMember member = _parser.parseClassMember(node.name.name);
      if (member == null) {
        throw new InsufficientContextException();
      }
      return member;
    }
    return _notAChild(node);
  }

  @override
  AstNode visitClassTypeAlias(ClassTypeAlias node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.name)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.typeParameters)) {
      return _parser.parseTypeParameterList();
    } else if (identical(_oldNode, node.superclass)) {
      return _parser.parseTypeName();
    } else if (identical(_oldNode, node.withClause)) {
      return _parser.parseWithClause();
    } else if (identical(_oldNode, node.implementsClause)) {
      return _parser.parseImplementsClause();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitComment(Comment node) {
    throw new InsufficientContextException();
  }

  @override
  AstNode visitCommentReference(CommentReference node) {
    if (identical(_oldNode, node.identifier)) {
      return _parser.parsePrefixedIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitCompilationUnit(CompilationUnit node) {
    throw new InsufficientContextException();
  }

  @override
  AstNode visitConditionalExpression(ConditionalExpression node) {
    if (identical(_oldNode, node.condition)) {
      return _parser.parseIfNullExpression();
    } else if (identical(_oldNode, node.thenExpression)) {
      return _parser.parseExpressionWithoutCascade();
    } else if (identical(_oldNode, node.elseExpression)) {
      return _parser.parseExpressionWithoutCascade();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitConstructorDeclaration(ConstructorDeclaration node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.returnType)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.name)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.parameters)) {
      return _parser.parseFormalParameterList();
    } else if (identical(_oldNode, node.redirectedConstructor)) {
      throw new InsufficientContextException();
    } else if (node.initializers.contains(_oldNode)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.body)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitConstructorFieldInitializer(ConstructorFieldInitializer node) {
    if (identical(_oldNode, node.fieldName)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.expression)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitConstructorName(ConstructorName node) {
    if (identical(_oldNode, node.type)) {
      return _parser.parseTypeName();
    } else if (identical(_oldNode, node.name)) {
      return _parser.parseSimpleIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitContinueStatement(ContinueStatement node) {
    if (identical(_oldNode, node.label)) {
      return _parser.parseSimpleIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitDeclaredIdentifier(DeclaredIdentifier node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.type)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.identifier)) {
      return _parser.parseSimpleIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitDefaultFormalParameter(DefaultFormalParameter node) {
    if (identical(_oldNode, node.parameter)) {
      return _parser.parseNormalFormalParameter();
    } else if (identical(_oldNode, node.defaultValue)) {
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitDoStatement(DoStatement node) {
    if (identical(_oldNode, node.body)) {
      return _parser.parseStatement2();
    } else if (identical(_oldNode, node.condition)) {
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitDoubleLiteral(DoubleLiteral node) => _notAChild(node);

  @override
  AstNode visitEmptyFunctionBody(EmptyFunctionBody node) => _notAChild(node);

  @override
  AstNode visitEmptyStatement(EmptyStatement node) => _notAChild(node);

  @override
  AstNode visitEnumConstantDeclaration(EnumConstantDeclaration node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.name)) {
      return _parser.parseSimpleIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitEnumDeclaration(EnumDeclaration node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.name)) {
      return _parser.parseSimpleIdentifier();
    } else if (node.constants.contains(_oldNode)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitExportDirective(ExportDirective node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.uri)) {
      return _parser.parseStringLiteral();
    } else if (node.combinators.contains(_oldNode)) {
      throw new IncrementalParseException();
      //return parser.parseCombinator();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitExpressionFunctionBody(ExpressionFunctionBody node) {
    if (identical(_oldNode, node.expression)) {
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitExpressionStatement(ExpressionStatement node) {
    if (identical(_oldNode, node.expression)) {
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitExtendsClause(ExtendsClause node) {
    if (identical(_oldNode, node.superclass)) {
      return _parser.parseTypeName();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitFieldDeclaration(FieldDeclaration node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.fields)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitFieldFormalParameter(FieldFormalParameter node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.type)) {
      return _parser.parseTypeName();
    } else if (identical(_oldNode, node.identifier)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.parameters)) {
      return _parser.parseFormalParameterList();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitForEachStatement(ForEachStatement node) {
    if (identical(_oldNode, node.loopVariable)) {
      throw new InsufficientContextException();
      //return parser.parseDeclaredIdentifier();
    } else if (identical(_oldNode, node.identifier)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.body)) {
      return _parser.parseStatement2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitFormalParameterList(FormalParameterList node) {
    // We don't know which kind of parameter to parse.
    throw new InsufficientContextException();
  }

  @override
  AstNode visitForStatement(ForStatement node) {
    if (identical(_oldNode, node.variables)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.initialization)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.condition)) {
      return _parser.parseExpression2();
    } else if (node.updaters.contains(_oldNode)) {
      return _parser.parseExpression2();
    } else if (identical(_oldNode, node.body)) {
      return _parser.parseStatement2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitFunctionDeclaration(FunctionDeclaration node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.returnType)) {
      return _parser.parseReturnType();
    } else if (identical(_oldNode, node.name)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.functionExpression)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    if (identical(_oldNode, node.functionDeclaration)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitFunctionExpression(FunctionExpression node) {
    if (identical(_oldNode, node.parameters)) {
      return _parser.parseFormalParameterList();
    } else if (identical(_oldNode, node.body)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (identical(_oldNode, node.function)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.argumentList)) {
      return _parser.parseArgumentList();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitFunctionTypeAlias(FunctionTypeAlias node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.returnType)) {
      return _parser.parseReturnType();
    } else if (identical(_oldNode, node.name)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.typeParameters)) {
      return _parser.parseTypeParameterList();
    } else if (identical(_oldNode, node.parameters)) {
      return _parser.parseFormalParameterList();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.returnType)) {
      return _parser.parseReturnType();
    } else if (identical(_oldNode, node.identifier)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.parameters)) {
      return _parser.parseFormalParameterList();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitHideCombinator(HideCombinator node) {
    if (node.hiddenNames.contains(_oldNode)) {
      return _parser.parseSimpleIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitIfStatement(IfStatement node) {
    if (identical(_oldNode, node.condition)) {
      return _parser.parseExpression2();
    } else if (identical(_oldNode, node.thenStatement)) {
      return _parser.parseStatement2();
    } else if (identical(_oldNode, node.elseStatement)) {
      return _parser.parseStatement2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitImplementsClause(ImplementsClause node) {
    if (node.interfaces.contains(node)) {
      return _parser.parseTypeName();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitImportDirective(ImportDirective node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.uri)) {
      return _parser.parseStringLiteral();
    } else if (identical(_oldNode, node.prefix)) {
      return _parser.parseSimpleIdentifier();
    } else if (node.combinators.contains(_oldNode)) {
      return _parser.parseCombinator();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitIndexExpression(IndexExpression node) {
    if (identical(_oldNode, node.target)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.index)) {
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (identical(_oldNode, node.constructorName)) {
      return _parser.parseConstructorName();
    } else if (identical(_oldNode, node.argumentList)) {
      return _parser.parseArgumentList();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitIntegerLiteral(IntegerLiteral node) => _notAChild(node);

  @override
  AstNode visitInterpolationExpression(InterpolationExpression node) {
    if (identical(_oldNode, node.expression)) {
      if (node.leftBracket == null) {
        throw new InsufficientContextException();
        //return parser.parseThisOrSimpleIdentifier();
      }
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitInterpolationString(InterpolationString node) {
    throw new InsufficientContextException();
  }

  @override
  AstNode visitIsExpression(IsExpression node) {
    if (identical(_oldNode, node.expression)) {
      return _parser.parseBitwiseOrExpression();
    } else if (identical(_oldNode, node.type)) {
      return _parser.parseTypeName();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitLabel(Label node) {
    if (identical(_oldNode, node.label)) {
      return _parser.parseSimpleIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitLabeledStatement(LabeledStatement node) {
    if (node.labels.contains(_oldNode)) {
      return _parser.parseLabel();
    } else if (identical(_oldNode, node.statement)) {
      return _parser.parseStatement2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitLibraryDirective(LibraryDirective node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.name)) {
      return _parser.parseLibraryIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitLibraryIdentifier(LibraryIdentifier node) {
    if (node.components.contains(_oldNode)) {
      return _parser.parseSimpleIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitListLiteral(ListLiteral node) {
    if (identical(_oldNode, node.typeArguments)) {
      return _parser.parseTypeArgumentList();
    } else if (node.elements.contains(_oldNode)) {
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitMapLiteral(MapLiteral node) {
    if (identical(_oldNode, node.typeArguments)) {
      return _parser.parseTypeArgumentList();
    } else if (node.entries.contains(_oldNode)) {
      return _parser.parseMapLiteralEntry();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitMapLiteralEntry(MapLiteralEntry node) {
    if (identical(_oldNode, node.key)) {
      return _parser.parseExpression2();
    } else if (identical(_oldNode, node.value)) {
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitMethodDeclaration(MethodDeclaration node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.returnType)) {
      throw new InsufficientContextException();
      //return parser.parseTypeName();
      //return parser.parseReturnType();
    } else if (identical(_oldNode, node.name)) {
      if (node.operatorKeyword != null) {
        throw new InsufficientContextException();
      }
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.body)) {
      //return parser.parseFunctionBody();
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.parameters)) {
      // TODO(paulberry): if we want errors to be correct, we'll need to also
      // call _validateFormalParameterList, and sometimes
      // _validateModifiersForGetterOrSetterOrMethod.
      return _parser.parseFormalParameterList();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitMethodInvocation(MethodInvocation node) {
    if (identical(_oldNode, node.target)) {
      throw new IncrementalParseException();
    } else if (identical(_oldNode, node.methodName)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.argumentList)) {
      return _parser.parseArgumentList();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitNamedExpression(NamedExpression node) {
    if (identical(_oldNode, node.name)) {
      return _parser.parseLabel();
    } else if (identical(_oldNode, node.expression)) {
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitNativeClause(NativeClause node) {
    if (identical(_oldNode, node.name)) {
      return _parser.parseStringLiteral();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitNativeFunctionBody(NativeFunctionBody node) {
    if (identical(_oldNode, node.stringLiteral)) {
      return _parser.parseStringLiteral();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitNullLiteral(NullLiteral node) => _notAChild(node);

  @override
  AstNode visitParenthesizedExpression(ParenthesizedExpression node) {
    if (identical(_oldNode, node.expression)) {
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitPartDirective(PartDirective node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.uri)) {
      return _parser.parseStringLiteral();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitPartOfDirective(PartOfDirective node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.libraryName)) {
      return _parser.parseLibraryIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitPostfixExpression(PostfixExpression node) {
    if (identical(_oldNode, node.operand)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (identical(_oldNode, node.prefix)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.identifier)) {
      return _parser.parseSimpleIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitPrefixExpression(PrefixExpression node) {
    if (identical(_oldNode, node.operand)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitPropertyAccess(PropertyAccess node) {
    if (identical(_oldNode, node.target)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.propertyName)) {
      return _parser.parseSimpleIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitRedirectingConstructorInvocation(
      RedirectingConstructorInvocation node) {
    if (identical(_oldNode, node.constructorName)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.argumentList)) {
      return _parser.parseArgumentList();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitRethrowExpression(RethrowExpression node) => _notAChild(node);

  @override
  AstNode visitReturnStatement(ReturnStatement node) {
    if (identical(_oldNode, node.expression)) {
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitScriptTag(ScriptTag node) => _notAChild(node);

  @override
  AstNode visitShowCombinator(ShowCombinator node) {
    if (node.shownNames.contains(_oldNode)) {
      return _parser.parseSimpleIdentifier();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitSimpleFormalParameter(SimpleFormalParameter node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.type)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.identifier)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitSimpleIdentifier(SimpleIdentifier node) => _notAChild(node);

  @override
  AstNode visitSimpleStringLiteral(SimpleStringLiteral node) =>
      _notAChild(node);

  @override
  AstNode visitStringInterpolation(StringInterpolation node) {
    if (node.elements.contains(_oldNode)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitSuperConstructorInvocation(SuperConstructorInvocation node) {
    if (identical(_oldNode, node.constructorName)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.argumentList)) {
      return _parser.parseArgumentList();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitSuperExpression(SuperExpression node) => _notAChild(node);

  @override
  AstNode visitSwitchCase(SwitchCase node) {
    if (node.labels.contains(_oldNode)) {
      return _parser.parseLabel();
    } else if (identical(_oldNode, node.expression)) {
      return _parser.parseExpression2();
    } else if (node.statements.contains(_oldNode)) {
      return _parser.parseStatement2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitSwitchDefault(SwitchDefault node) {
    if (node.labels.contains(_oldNode)) {
      return _parser.parseLabel();
    } else if (node.statements.contains(_oldNode)) {
      return _parser.parseStatement2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitSwitchStatement(SwitchStatement node) {
    if (identical(_oldNode, node.expression)) {
      return _parser.parseExpression2();
    } else if (node.members.contains(_oldNode)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitSymbolLiteral(SymbolLiteral node) => _notAChild(node);

  @override
  AstNode visitThisExpression(ThisExpression node) => _notAChild(node);

  @override
  AstNode visitThrowExpression(ThrowExpression node) {
    if (identical(_oldNode, node.expression)) {
      if (_isCascadeAllowedInThrow(node)) {
        return _parser.parseExpression2();
      }
      return _parser.parseExpressionWithoutCascade();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.variables)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitTryStatement(TryStatement node) {
    if (identical(_oldNode, node.body)) {
      return _parser.parseBlock();
    } else if (node.catchClauses.contains(_oldNode)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.finallyBlock)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitTypeArgumentList(TypeArgumentList node) {
    if (node.arguments.contains(_oldNode)) {
      return _parser.parseTypeName();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitTypeName(TypeName node) {
    if (identical(_oldNode, node.name)) {
      return _parser.parsePrefixedIdentifier();
    } else if (identical(_oldNode, node.typeArguments)) {
      return _parser.parseTypeArgumentList();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitTypeParameter(TypeParameter node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.name)) {
      return _parser.parseSimpleIdentifier();
    } else if (identical(_oldNode, node.bound)) {
      return _parser.parseTypeName();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitTypeParameterList(TypeParameterList node) {
    if (node.typeParameters.contains(node)) {
      return _parser.parseTypeParameter();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitVariableDeclaration(VariableDeclaration node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.name)) {
      throw new InsufficientContextException();
    } else if (identical(_oldNode, node.initializer)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitVariableDeclarationList(VariableDeclarationList node) {
    if (identical(_oldNode, node.documentationComment)) {
      throw new InsufficientContextException();
    } else if (node.metadata.contains(_oldNode)) {
      return _parser.parseAnnotation();
    } else if (identical(_oldNode, node.type)) {
      // There is not enough context to know whether we should reparse the type
      // using parseReturnType() (which allows 'void') or parseTypeName()
      // (which doesn't).  Note that even though the language disallows
      // variables of type 'void', the parser sometimes accepts them in the
      // course of error recovery (e.g. "class C { void v; }"
      throw new InsufficientContextException();
    } else if (node.variables.contains(_oldNode)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    if (identical(_oldNode, node.variables)) {
      throw new InsufficientContextException();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitWhileStatement(WhileStatement node) {
    if (identical(_oldNode, node.condition)) {
      return _parser.parseExpression2();
    } else if (identical(_oldNode, node.body)) {
      return _parser.parseStatement2();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitWithClause(WithClause node) {
    if (node.mixinTypes.contains(node)) {
      return _parser.parseTypeName();
    }
    return _notAChild(node);
  }

  @override
  AstNode visitYieldStatement(YieldStatement node) {
    if (identical(_oldNode, node.expression)) {
      return _parser.parseExpression2();
    }
    return _notAChild(node);
  }

  /**
   * Return `true` if the given assignment [expression] can have a cascade
   * expression on the right-hand side.
   */
  bool _isCascadeAllowedInAssignment(AssignmentExpression expression) {
    // TODO(brianwilkerson) Implement this method.
    throw new InsufficientContextException();
  }

  /**
   * Return `true` if the given throw [expression] can have a cascade
   * expression.
   */
  bool _isCascadeAllowedInThrow(ThrowExpression expression) {
    // TODO(brianwilkerson) Implement this method.
    throw new InsufficientContextException();
  }

  /**
   * Throw an exception indicating that the visited [node] was not the parent of
   * the node to be replaced.
   */
  AstNode _notAChild(AstNode node) {
    throw new IncrementalParseException.con1(
        "Internal error: the visited node (a ${node.runtimeType}) was not the parent of the node to be replaced (a ${_oldNode.runtimeType})");
  }
}

/**
 * An exception that occurred while attempting to parse a replacement for a
 * specified node in an existing AST structure.
 */
class IncrementalParseException extends RuntimeException {
  /**
   * Initialize a newly created exception to have no message and to be its own
   * cause.
   */
  IncrementalParseException() : super();

  /**
   * Initialize a newly created exception to have the given [message] and to be
   * its own cause.
   */
  IncrementalParseException.con1(String message) : super(message: message);

  /**
   * Initialize a newly created exception to have no message and to have the
   * given [cause].
   */
  IncrementalParseException.con2(Exception cause) : super(cause: cause);
}

/**
 * An object used to re-parse a single AST structure within a larger AST
 * structure.
 */
class IncrementalParser {
  /**
   * The source being parsed.
   */
  final Source _source;

  /**
   * A map from old tokens to new tokens used during the cloning process.
   */
  final TokenMap _tokenMap;

  /**
   * The error listener that will be informed of any errors that are found
   * during the parse.
   */
  final AnalysisErrorListener _errorListener;

  /**
   * The node in the AST structure that contains the revised content.
   */
  AstNode _updatedNode;

  /**
   * Initialize a newly created incremental parser to parse a portion of the
   * content of the given [_source]. The [_tokenMap] is a map from old tokens to
   * new tokens that is used during the cloning process. The [_errorListener]
   * will be informed of any errors that are found during the parse.
   */
  IncrementalParser(this._source, this._tokenMap, this._errorListener);

  /**
   * Return the node in the AST structure that contains the revised content.
   */
  AstNode get updatedNode => _updatedNode;

  /**
   * Given a range of tokens that were re-scanned, re-parse the minimum number
   * of tokens to produce a consistent AST structure. The range is represented
   * by the first and last tokens in the range.
   *
   * More specifically, the [leftToken] is the token in the new token stream
   * immediately to the left of the range of tokens that were inserted and the
   * [rightToken] is the token in the new token stream immediately to the right
   * of the range of tokens that were inserted. The [originalStart] and
   * [originalEnd] are the offsets in the original source of the first and last
   * characters that were modified.
   *
   * The tokens are assumed to be contained in the same token stream.
   */
  AstNode reparse(AstNode originalStructure, Token leftToken, Token rightToken,
      int originalStart, int originalEnd) {
    AstNode oldNode = null;
    AstNode newNode = null;
    //
    // Find the first token that needs to be re-parsed.
    //
    Token firstToken = leftToken.next;
    if (identical(firstToken, rightToken)) {
      // If there are no new tokens, then we need to include at least one copied
      // node in the range.
      firstToken = leftToken;
    }
    //
    // Find the smallest AST node that encompasses the range of re-scanned
    // tokens.
    //
    if (originalEnd < originalStart) {
      oldNode = new NodeLocator(originalStart).searchWithin(originalStructure);
    } else {
      oldNode = new NodeLocator(originalStart, originalEnd)
          .searchWithin(originalStructure);
    }
    //
    // Find the token at which parsing is to begin.
    //
    int originalOffset = oldNode.offset;
    Token parseToken = _findTokenAt(firstToken, originalOffset);
    if (parseToken == null) {
      return null;
    }
    //
    // Parse the appropriate AST structure starting at the appropriate place.
    //
    Parser parser = new Parser(_source, _errorListener);
    parser.currentToken = parseToken;
    while (newNode == null) {
      AstNode parent = oldNode.parent;
      if (parent == null) {
        parseToken = _findFirstToken(parseToken);
        parser.currentToken = parseToken;
        return parser.parseCompilationUnit2();
      }
      bool advanceToParent = false;
      try {
        IncrementalParseDispatcher dispatcher =
            new IncrementalParseDispatcher(parser, oldNode);
        IncrementalParseStateBuilder contextBuilder =
            new IncrementalParseStateBuilder(parser);
        contextBuilder.buildState(oldNode);
        newNode = parent.accept(dispatcher);
        //
        // Validate that the new node can replace the old node.
        //
        Token mappedToken = _tokenMap.get(oldNode.endToken.next);
        if (mappedToken == null ||
            newNode == null ||
            mappedToken.offset != newNode.endToken.next.offset ||
            newNode.offset != oldNode.offset) {
          advanceToParent = true;
        }
      } on InsufficientContextException {
        advanceToParent = true;
      } catch (exception) {
        return null;
      }
      if (advanceToParent) {
        newNode = null;
        oldNode = parent;
        originalOffset = oldNode.offset;
        parseToken = _findTokenAt(parseToken, originalOffset);
        parser.currentToken = parseToken;
      }
    }
    _updatedNode = newNode;
    //
    // Replace the old node with the new node in a copy of the original AST
    // structure.
    //
    if (identical(oldNode, originalStructure)) {
      // We ended up re-parsing the whole structure, so there's no need for a
      // copy.
      ResolutionCopier.copyResolutionData(oldNode, newNode);
      return newNode;
    }
    ResolutionCopier.copyResolutionData(oldNode, newNode);
    IncrementalAstCloner cloner =
        new IncrementalAstCloner(oldNode, newNode, _tokenMap);
    return originalStructure.accept(cloner) as AstNode;
  }

  /**
   * Return the first (non-EOF) token in the token stream containing the
   * [firstToken].
   */
  Token _findFirstToken(Token firstToken) {
    while (firstToken.type != TokenType.EOF) {
      firstToken = firstToken.previous;
    }
    return firstToken.next;
  }

  /**
   * Find the token at or before the [firstToken] with the given [offset], or
   * `null` if there is no such token.
   */
  Token _findTokenAt(Token firstToken, int offset) {
    while (firstToken.offset > offset && firstToken.type != TokenType.EOF) {
      firstToken = firstToken.previous;
    }
    return firstToken;
  }
}

/**
 * A visitor capable of inferring the correct parser state for incremental
 * parsing.  This visitor visits each parent/child relationship in the chain of
 * ancestors of the node to be replaced (starting with the root of the parse
 * tree), updating the parser to the correct state for parsing the child of the
 * given parent.  Once it has visited all of these relationships, the parser
 * will be in the correct state for reparsing the node to be replaced.
 */
class IncrementalParseStateBuilder extends SimpleAstVisitor {
  // TODO(paulberry): add support for other pieces of parser state (_inAsync,
  // _inGenerator, _inLoop, and _inSwitch).  Note that _inLoop and _inSwitch
  // only affect error message generation.

  /**
   * The parser whose state should be built.
   */
  final Parser _parser;

  /**
   * The child node in the parent/child relationship currently being visited.
   * (The corresponding parent is the node passed to the visit...() function.)
   */
  AstNode _childNode;

  /**
   * Create an IncrementalParseStateBuilder which will build the correct state
   * for [_parser].
   */
  IncrementalParseStateBuilder(this._parser);

  /**
   * Build the correct parser state for parsing a replacement for [node].
   */
  void buildState(AstNode node) {
    List<AstNode> ancestors = <AstNode>[];
    while (node != null) {
      ancestors.add(node);
      node = node.parent;
    }
    _parser._inInitializer = false;
    for (int i = ancestors.length - 2; i >= 0; i--) {
      _childNode = ancestors[i];
      ancestors[i + 1].accept(this);
    }
  }

  @override
  void visitArgumentList(ArgumentList node) {
    _parser._inInitializer = false;
  }

  @override
  void visitConstructorFieldInitializer(ConstructorFieldInitializer node) {
    if (identical(_childNode, node.expression)) {
      _parser._inInitializer = true;
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    if (identical(_childNode, node.index)) {
      _parser._inInitializer = false;
    }
  }

  @override
  void visitInterpolationExpression(InterpolationExpression node) {
    if (identical(_childNode, node.expression)) {
      _parser._inInitializer = false;
    }
  }

  @override
  void visitListLiteral(ListLiteral node) {
    if (node.elements.contains(_childNode)) {
      _parser._inInitializer = false;
    }
  }

  @override
  void visitMapLiteral(MapLiteral node) {
    if (node.entries.contains(_childNode)) {
      _parser._inInitializer = false;
    }
  }

  @override
  void visitParenthesizedExpression(ParenthesizedExpression node) {
    if (identical(_childNode, node.expression)) {
      _parser._inInitializer = false;
    }
  }
}

/**
 * An exception indicating that an AST node cannot be re-parsed because there is
 * not enough context to know how to re-parse the node. Clients can attempt to
 * re-parse the parent of the node.
 */
class InsufficientContextException extends IncrementalParseException {
  /**
   * Initialize a newly created exception to have no message and to be its own
   * cause.
   */
  InsufficientContextException() : super();

  /**
   * Initialize a newly created exception to have the given [message] and to be
   * its own cause.
   */
  InsufficientContextException.con1(String message) : super.con1(message);

  /**
   * Initialize a newly created exception to have no message and to have the
   * given [cause].
   */
  InsufficientContextException.con2(Exception cause) : super.con2(cause);
}

/**
 * Wrapper around [Function] which should be called with "target" and
 * "arguments".
 */
class MethodTrampoline {
  int parameterCount;
  Function trampoline;
  MethodTrampoline(this.parameterCount, this.trampoline);
  Object invoke(target, List arguments) {
    if (arguments.length != parameterCount) {
      throw new IllegalArgumentException(
          "${arguments.length} != $parameterCount");
    }
    switch (parameterCount) {
      case 0:
        return trampoline(target);
      case 1:
        return trampoline(target, arguments[0]);
      case 2:
        return trampoline(target, arguments[0], arguments[1]);
      case 3:
        return trampoline(target, arguments[0], arguments[1], arguments[2]);
      case 4:
        return trampoline(
            target, arguments[0], arguments[1], arguments[2], arguments[3]);
      default:
        throw new IllegalArgumentException("Not implemented for > 4 arguments");
    }
  }
}

/**
 * A simple data-holder for a method that needs to return multiple values.
 */
class Modifiers {
  /**
   * The token representing the keyword 'abstract', or `null` if the keyword was
   * not found.
   */
  Token abstractKeyword;

  /**
   * The token representing the keyword 'const', or `null` if the keyword was
   * not found.
   */
  Token constKeyword;

  /**
   * The token representing the keyword 'external', or `null` if the keyword was
   * not found.
   */
  Token externalKeyword;

  /**
   * The token representing the keyword 'factory', or `null` if the keyword was
   * not found.
   */
  Token factoryKeyword;

  /**
   * The token representing the keyword 'final', or `null` if the keyword was
   * not found.
   */
  Token finalKeyword;

  /**
   * The token representing the keyword 'static', or `null` if the keyword was
   * not found.
   */
  Token staticKeyword;

  /**
   * The token representing the keyword 'var', or `null` if the keyword was not
   * found.
   */
  Token varKeyword;

  @override
  String toString() {
    StringBuffer buffer = new StringBuffer();
    bool needsSpace = _appendKeyword(buffer, false, abstractKeyword);
    needsSpace = _appendKeyword(buffer, needsSpace, constKeyword);
    needsSpace = _appendKeyword(buffer, needsSpace, externalKeyword);
    needsSpace = _appendKeyword(buffer, needsSpace, factoryKeyword);
    needsSpace = _appendKeyword(buffer, needsSpace, finalKeyword);
    needsSpace = _appendKeyword(buffer, needsSpace, staticKeyword);
    _appendKeyword(buffer, needsSpace, varKeyword);
    return buffer.toString();
  }

  /**
   * If the given [keyword] is not `null`, append it to the given [builder],
   * prefixing it with a space if [needsSpace] is `true`. Return `true` if
   * subsequent keywords need to be prefixed with a space.
   */
  bool _appendKeyword(StringBuffer buffer, bool needsSpace, Token keyword) {
    if (keyword != null) {
      if (needsSpace) {
        buffer.writeCharCode(0x20);
      }
      buffer.write(keyword.lexeme);
      return true;
    }
    return needsSpace;
  }
}

/**
 * A parser used to parse tokens into an AST structure.
 */
class Parser {
  static String ASYNC = "async";

  static String _AWAIT = "await";

  static String _HIDE = "hide";

  static String _OF = "of";

  static String _ON = "on";

  static String _NATIVE = "native";

  static String _SHOW = "show";

  static String SYNC = "sync";

  static String _YIELD = "yield";

  /**
   * The source being parsed.
   */
  final Source _source;

  /**
   * The error listener that will be informed of any errors that are found
   * during the parse.
   */
  final AnalysisErrorListener _errorListener;

  /**
   * An [errorListener] lock, if more than `0`, then errors are not reported.
   */
  int _errorListenerLock = 0;

  /**
   * A flag indicating whether parser is to parse function bodies.
   */
  bool _parseFunctionBodies = true;

  /**
   * The next token to be parsed.
   */
  Token _currentToken;

  /**
   * A flag indicating whether the parser is currently in a function body marked
   * as being 'async'.
   */
  bool _inAsync = false;

  /**
   * A flag indicating whether the parser is currently in a function body marked
   * as being 'async'.
   */
  bool _inGenerator = false;

  /**
   * A flag indicating whether the parser is currently in the body of a loop.
   */
  bool _inLoop = false;

  /**
   * A flag indicating whether the parser is currently in a switch statement.
   */
  bool _inSwitch = false;

  /**
   * A flag indicating whether the parser is currently in a constructor field
   * initializer, with no intervening parens, braces, or brackets.
   */
  bool _inInitializer = false;

  /**
   * A flag indicating whether the parser is to parse generic method syntax.
   */
  bool parseGenericMethods = false;

  /**
   * Initialize a newly created parser to parse the content of the given
   * [_source] and to report any errors that are found to the given
   * [_errorListener].
   */
  Parser(this._source, this._errorListener);

  void set currentToken(Token currentToken) {
    this._currentToken = currentToken;
  }

  /**
   * Return `true` if the current token is the first token of a return type that
   * is followed by an identifier, possibly followed by a list of type
   * parameters, followed by a left-parenthesis. This is used by
   * [_parseTypeAlias] to determine whether or not to parse a return type.
   */
  bool get hasReturnTypeInTypeAlias {
    Token next = _skipReturnType(_currentToken);
    if (next == null) {
      return false;
    }
    return _tokenMatchesIdentifier(next);
  }

  /**
   * Set whether the parser is to parse the async support.
   */
  @deprecated
  void set parseAsync(bool parseAsync) {
    // Async support cannot be disabled
  }

  /**
   * Set whether the parser is to parse deferred libraries.
   */
  @deprecated
  void set parseDeferredLibraries(bool parseDeferredLibraries) {
    // Deferred libraries support cannot be disabled
  }

  /**
   * Set whether the parser is to parse enum declarations.
   */
  @deprecated
  void set parseEnum(bool parseEnum) {
    // Enum support cannot be disabled
  }

  /**
   * Set whether parser is to parse function bodies.
   */
  void set parseFunctionBodies(bool parseFunctionBodies) {
    this._parseFunctionBodies = parseFunctionBodies;
  }

  /**
   * Advance to the next token in the token stream, making it the new current
   * token and return the token that was current before this method was invoked.
   */
  Token getAndAdvance() {
    Token token = _currentToken;
    _advance();
    return token;
  }

  /**
   * Parse an annotation. Return the annotation that was parsed.
   *
   *     annotation ::=
   *         '@' qualified ('.' identifier)? arguments?
   *
   */
  Annotation parseAnnotation() {
    Token atSign = _expect(TokenType.AT);
    Identifier name = parsePrefixedIdentifier();
    Token period = null;
    SimpleIdentifier constructorName = null;
    if (_matches(TokenType.PERIOD)) {
      period = getAndAdvance();
      constructorName = parseSimpleIdentifier();
    }
    ArgumentList arguments = null;
    if (_matches(TokenType.OPEN_PAREN)) {
      arguments = parseArgumentList();
    }
    return new Annotation(atSign, name, period, constructorName, arguments);
  }

  /**
   * Parse an argument. Return the argument that was parsed.
   *
   *     argument ::=
   *         namedArgument
   *       | expression
   *
   *     namedArgument ::=
   *         label expression
   */
  Expression parseArgument() {
    //
    // Both namedArgument and expression can start with an identifier, but only
    // namedArgument can have an identifier followed by a colon.
    //
    if (_matchesIdentifier() && _tokenMatches(_peek(), TokenType.COLON)) {
      return new NamedExpression(parseLabel(), parseExpression2());
    } else {
      return parseExpression2();
    }
  }

  /**
   * Parse a list of arguments. Return the argument list that was parsed.
   *
   *     arguments ::=
   *         '(' argumentList? ')'
   *
   *     argumentList ::=
   *         namedArgument (',' namedArgument)*
   *       | expressionList (',' namedArgument)*
   */
  ArgumentList parseArgumentList() {
    Token leftParenthesis = _expect(TokenType.OPEN_PAREN);
    List<Expression> arguments = new List<Expression>();
    if (_matches(TokenType.CLOSE_PAREN)) {
      return new ArgumentList(leftParenthesis, arguments, getAndAdvance());
    }
    //
    // Even though unnamed arguments must all appear before any named arguments,
    // we allow them to appear in any order so that we can recover faster.
    //
    bool wasInInitializer = _inInitializer;
    _inInitializer = false;
    try {
      Expression argument = parseArgument();
      arguments.add(argument);
      bool foundNamedArgument = argument is NamedExpression;
      bool generatedError = false;
      while (_optional(TokenType.COMMA)) {
        argument = parseArgument();
        arguments.add(argument);
        if (foundNamedArgument) {
          bool blankArgument =
              argument is SimpleIdentifier && argument.name.isEmpty;
          if (!generatedError &&
              !(argument is NamedExpression && !blankArgument)) {
            // Report the error, once, but allow the arguments to be in any
            // order in the AST.
            _reportErrorForCurrentToken(
                ParserErrorCode.POSITIONAL_AFTER_NAMED_ARGUMENT);
            generatedError = true;
          }
        } else if (argument is NamedExpression) {
          foundNamedArgument = true;
        }
      }
      // TODO(brianwilkerson) Recovery: Look at the left parenthesis to see
      // whether there is a matching right parenthesis. If there is, then we're
      // more likely missing a comma and should go back to parsing arguments.
      Token rightParenthesis = _expect(TokenType.CLOSE_PAREN);
      return new ArgumentList(leftParenthesis, arguments, rightParenthesis);
    } finally {
      _inInitializer = wasInInitializer;
    }
  }

  /**
   * Parse a bitwise or expression. Return the bitwise or expression that was
   * parsed.
   *
   *     bitwiseOrExpression ::=
   *         bitwiseXorExpression ('|' bitwiseXorExpression)*
   *       | 'super' ('|' bitwiseXorExpression)+
   */
  Expression parseBitwiseOrExpression() {
    Expression expression;
    if (_matchesKeyword(Keyword.SUPER) &&
        _tokenMatches(_peek(), TokenType.BAR)) {
      expression = new SuperExpression(getAndAdvance());
    } else {
      expression = _parseBitwiseXorExpression();
    }
    while (_matches(TokenType.BAR)) {
      Token operator = getAndAdvance();
      expression = new BinaryExpression(
          expression, operator, _parseBitwiseXorExpression());
    }
    return expression;
  }

  /**
   * Parse a block. Return the block that was parsed.
   *
   *     block ::=
   *         '{' statements '}'
   */
  Block parseBlock() {
    Token leftBracket = _expect(TokenType.OPEN_CURLY_BRACKET);
    List<Statement> statements = new List<Statement>();
    Token statementStart = _currentToken;
    while (
        !_matches(TokenType.EOF) && !_matches(TokenType.CLOSE_CURLY_BRACKET)) {
      Statement statement = parseStatement2();
      if (statement != null) {
        statements.add(statement);
      }
      if (identical(_currentToken, statementStart)) {
        // Ensure that we are making progress and report an error if we're not.
        _reportErrorForToken(ParserErrorCode.UNEXPECTED_TOKEN, _currentToken,
            [_currentToken.lexeme]);
        _advance();
      }
      statementStart = _currentToken;
    }
    Token rightBracket = _expect(TokenType.CLOSE_CURLY_BRACKET);
    return new Block(leftBracket, statements, rightBracket);
  }

  /**
   * Parse a class member. The [className] is the name of the class containing
   * the member being parsed. Return the class member that was parsed, or `null`
   * if what was found was not a valid class member.
   *
   *     classMemberDefinition ::=
   *         declaration ';'
   *       | methodSignature functionBody
   */
  ClassMember parseClassMember(String className) {
    CommentAndMetadata commentAndMetadata = _parseCommentAndMetadata();
    Modifiers modifiers = _parseModifiers();
    if (_matchesKeyword(Keyword.VOID)) {
      TypeName returnType = parseReturnType();
      if (_matchesKeyword(Keyword.GET) && _tokenMatchesIdentifier(_peek())) {
        _validateModifiersForGetterOrSetterOrMethod(modifiers);
        return _parseGetter(commentAndMetadata, modifiers.externalKeyword,
            modifiers.staticKeyword, returnType);
      } else if (_matchesKeyword(Keyword.SET) &&
          _tokenMatchesIdentifier(_peek())) {
        _validateModifiersForGetterOrSetterOrMethod(modifiers);
        return _parseSetter(commentAndMetadata, modifiers.externalKeyword,
            modifiers.staticKeyword, returnType);
      } else if (_matchesKeyword(Keyword.OPERATOR) && _isOperator(_peek())) {
        _validateModifiersForOperator(modifiers);
        return _parseOperator(
            commentAndMetadata, modifiers.externalKeyword, returnType);
      } else if (_matchesIdentifier() &&
          _peek().matchesAny([
        TokenType.OPEN_PAREN,
        TokenType.OPEN_CURLY_BRACKET,
        TokenType.FUNCTION,
        TokenType.LT
      ])) {
        _validateModifiersForGetterOrSetterOrMethod(modifiers);
        return _parseMethodDeclarationAfterReturnType(commentAndMetadata,
            modifiers.externalKeyword, modifiers.staticKeyword, returnType);
      } else {
        //
        // We have found an error of some kind. Try to recover.
        //
        if (_matchesIdentifier()) {
          if (_peek().matchesAny(
              [TokenType.EQ, TokenType.COMMA, TokenType.SEMICOLON])) {
            //
            // We appear to have a variable declaration with a type of "void".
            //
            _reportErrorForNode(ParserErrorCode.VOID_VARIABLE, returnType);
            return _parseInitializedIdentifierList(commentAndMetadata,
                modifiers.staticKeyword, _validateModifiersForField(modifiers),
                returnType);
          }
        }
        if (_isOperator(_currentToken)) {
          //
          // We appear to have found an operator declaration without the
          // 'operator' keyword.
          //
          _validateModifiersForOperator(modifiers);
          return _parseOperator(
              commentAndMetadata, modifiers.externalKeyword, returnType);
        }
        _reportErrorForToken(
            ParserErrorCode.EXPECTED_EXECUTABLE, _currentToken);
        return null;
      }
    } else if (_matchesKeyword(Keyword.GET) &&
        _tokenMatchesIdentifier(_peek())) {
      _validateModifiersForGetterOrSetterOrMethod(modifiers);
      return _parseGetter(commentAndMetadata, modifiers.externalKeyword,
          modifiers.staticKeyword, null);
    } else if (_matchesKeyword(Keyword.SET) &&
        _tokenMatchesIdentifier(_peek())) {
      _validateModifiersForGetterOrSetterOrMethod(modifiers);
      return _parseSetter(commentAndMetadata, modifiers.externalKeyword,
          modifiers.staticKeyword, null);
    } else if (_matchesKeyword(Keyword.OPERATOR) && _isOperator(_peek())) {
      _validateModifiersForOperator(modifiers);
      return _parseOperator(
          commentAndMetadata, modifiers.externalKeyword, null);
    } else if (!_matchesIdentifier()) {
      //
      // Recover from an error.
      //
      if (_matchesKeyword(Keyword.CLASS)) {
        _reportErrorForCurrentToken(ParserErrorCode.CLASS_IN_CLASS);
        // TODO(brianwilkerson) We don't currently have any way to capture the
        // class that was parsed.
        _parseClassDeclaration(commentAndMetadata, null);
        return null;
      } else if (_matchesKeyword(Keyword.ABSTRACT) &&
          _tokenMatchesKeyword(_peek(), Keyword.CLASS)) {
        _reportErrorForToken(ParserErrorCode.CLASS_IN_CLASS, _peek());
        // TODO(brianwilkerson) We don't currently have any way to capture the
        // class that was parsed.
        _parseClassDeclaration(commentAndMetadata, getAndAdvance());
        return null;
      } else if (_matchesKeyword(Keyword.ENUM)) {
        _reportErrorForToken(ParserErrorCode.ENUM_IN_CLASS, _peek());
        // TODO(brianwilkerson) We don't currently have any way to capture the
        // enum that was parsed.
        _parseEnumDeclaration(commentAndMetadata);
        return null;
      } else if (_isOperator(_currentToken)) {
        //
        // We appear to have found an operator declaration without the
        // 'operator' keyword.
        //
        _validateModifiersForOperator(modifiers);
        return _parseOperator(
            commentAndMetadata, modifiers.externalKeyword, null);
      }
      Token keyword = modifiers.varKeyword;
      if (keyword == null) {
        keyword = modifiers.finalKeyword;
      }
      if (keyword == null) {
        keyword = modifiers.constKeyword;
      }
      if (keyword != null) {
        //
        // We appear to have found an incomplete field declaration.
        //
        _reportErrorForCurrentToken(ParserErrorCode.MISSING_IDENTIFIER);
        List<VariableDeclaration> variables = new List<VariableDeclaration>();
        variables.add(
            new VariableDeclaration(_createSyntheticIdentifier(), null, null));
        return new FieldDeclaration(commentAndMetadata.comment,
            commentAndMetadata.metadata, null,
            new VariableDeclarationList(null, null, keyword, null, variables),
            _expectSemicolon());
      }
      _reportErrorForToken(
          ParserErrorCode.EXPECTED_CLASS_MEMBER, _currentToken);
      if (commentAndMetadata.comment != null ||
          !commentAndMetadata.metadata.isEmpty) {
        //
        // We appear to have found an incomplete declaration at the end of the
        // class. At this point it consists of a metadata, which we don't want
        // to loose, so we'll treat it as a method declaration with a missing
        // name, parameters and empty body.
        //
        return new MethodDeclaration(commentAndMetadata.comment,
            commentAndMetadata.metadata, null, null, null, null, null,
            _createSyntheticIdentifier(), null, new FormalParameterList(
                null, new List<FormalParameter>(), null, null, null),
            new EmptyFunctionBody(_createSyntheticToken(TokenType.SEMICOLON)));
      }
      return null;
    } else if (_tokenMatches(_peek(), TokenType.PERIOD) &&
        _tokenMatchesIdentifier(_peekAt(2)) &&
        _tokenMatches(_peekAt(3), TokenType.OPEN_PAREN)) {
      return _parseConstructor(commentAndMetadata, modifiers.externalKeyword,
          _validateModifiersForConstructor(modifiers), modifiers.factoryKeyword,
          parseSimpleIdentifier(), getAndAdvance(), parseSimpleIdentifier(),
          parseFormalParameterList());
    } else if (_tokenMatches(_peek(), TokenType.OPEN_PAREN)) {
      SimpleIdentifier methodName = parseSimpleIdentifier();
      FormalParameterList parameters = parseFormalParameterList();
      if (_matches(TokenType.COLON) ||
          modifiers.factoryKeyword != null ||
          methodName.name == className) {
        return _parseConstructor(commentAndMetadata, modifiers.externalKeyword,
            _validateModifiersForConstructor(modifiers),
            modifiers.factoryKeyword, methodName, null, null, parameters);
      }
      _validateModifiersForGetterOrSetterOrMethod(modifiers);
      _validateFormalParameterList(parameters);
      return _parseMethodDeclarationAfterParameters(commentAndMetadata,
          modifiers.externalKeyword, modifiers.staticKeyword, null, methodName,
          null, parameters);
    } else if (_peek()
        .matchesAny([TokenType.EQ, TokenType.COMMA, TokenType.SEMICOLON])) {
      if (modifiers.constKeyword == null &&
          modifiers.finalKeyword == null &&
          modifiers.varKeyword == null) {
        _reportErrorForCurrentToken(
            ParserErrorCode.MISSING_CONST_FINAL_VAR_OR_TYPE);
      }
      return _parseInitializedIdentifierList(commentAndMetadata,
          modifiers.staticKeyword, _validateModifiersForField(modifiers), null);
    } else if (_matchesKeyword(Keyword.TYPEDEF)) {
      _reportErrorForCurrentToken(ParserErrorCode.TYPEDEF_IN_CLASS);
      // TODO(brianwilkerson) We don't currently have any way to capture the
      // function type alias that was parsed.
      _parseFunctionTypeAlias(commentAndMetadata, getAndAdvance());
      return null;
    } else if (parseGenericMethods) {
      Token token = _skipTypeParameterList(_peek());
      if (token != null && _tokenMatches(token, TokenType.OPEN_PAREN)) {
        return _parseMethodDeclarationAfterReturnType(commentAndMetadata,
            modifiers.externalKeyword, modifiers.staticKeyword, null);
      }
    }
    TypeName type = parseTypeName();
    if (_matchesKeyword(Keyword.GET) && _tokenMatchesIdentifier(_peek())) {
      _validateModifiersForGetterOrSetterOrMethod(modifiers);
      return _parseGetter(commentAndMetadata, modifiers.externalKeyword,
          modifiers.staticKeyword, type);
    } else if (_matchesKeyword(Keyword.SET) &&
        _tokenMatchesIdentifier(_peek())) {
      _validateModifiersForGetterOrSetterOrMethod(modifiers);
      return _parseSetter(commentAndMetadata, modifiers.externalKeyword,
          modifiers.staticKeyword, type);
    } else if (_matchesKeyword(Keyword.OPERATOR) && _isOperator(_peek())) {
      _validateModifiersForOperator(modifiers);
      return _parseOperator(
          commentAndMetadata, modifiers.externalKeyword, type);
    } else if (!_matchesIdentifier()) {
      if (_matches(TokenType.CLOSE_CURLY_BRACKET)) {
        //
        // We appear to have found an incomplete declaration at the end of the
        // class. At this point it consists of a type name, so we'll treat it as
        // a field declaration with a missing field name and semicolon.
        //
        return _parseInitializedIdentifierList(commentAndMetadata,
            modifiers.staticKeyword, _validateModifiersForField(modifiers),
            type);
      }
      if (_isOperator(_currentToken)) {
        //
        // We appear to have found an operator declaration without the
        // 'operator' keyword.
        //
        _validateModifiersForOperator(modifiers);
        return _parseOperator(
            commentAndMetadata, modifiers.externalKeyword, type);
      }
      //
      // We appear to have found an incomplete declaration before another
      // declaration. At this point it consists of a type name, so we'll treat
      // it as a field declaration with a missing field name and semicolon.
      //
      _reportErrorForToken(
          ParserErrorCode.EXPECTED_CLASS_MEMBER, _currentToken);
      try {
        _lockErrorListener();
        return _parseInitializedIdentifierList(commentAndMetadata,
            modifiers.staticKeyword, _validateModifiersForField(modifiers),
            type);
      } finally {
        _unlockErrorListener();
      }
    } else if (_tokenMatches(_peek(), TokenType.OPEN_PAREN)) {
      SimpleIdentifier methodName = parseSimpleIdentifier();
      FormalParameterList parameters = parseFormalParameterList();
      if (methodName.name == className) {
        _reportErrorForNode(ParserErrorCode.CONSTRUCTOR_WITH_RETURN_TYPE, type);
        return _parseConstructor(commentAndMetadata, modifiers.externalKeyword,
            _validateModifiersForConstructor(modifiers),
            modifiers.factoryKeyword, methodName, null, null, parameters);
      }
      _validateModifiersForGetterOrSetterOrMethod(modifiers);
      _validateFormalParameterList(parameters);
      return _parseMethodDeclarationAfterParameters(commentAndMetadata,
          modifiers.externalKeyword, modifiers.staticKeyword, type, methodName,
          null, parameters);
    } else if (parseGenericMethods && _tokenMatches(_peek(), TokenType.LT)) {
      return _parseMethodDeclarationAfterReturnType(commentAndMetadata,
          modifiers.externalKeyword, modifiers.staticKeyword, type);
    } else if (_tokenMatches(_peek(), TokenType.OPEN_CURLY_BRACKET)) {
      // We have found "TypeName identifier {", and are guessing that this is a
      // getter without the keyword 'get'.
      _validateModifiersForGetterOrSetterOrMethod(modifiers);
      _reportErrorForCurrentToken(ParserErrorCode.MISSING_GET);
      _currentToken = _injectToken(
          new Parser_SyntheticKeywordToken(Keyword.GET, _currentToken.offset));
      return _parseGetter(commentAndMetadata, modifiers.externalKeyword,
          modifiers.staticKeyword, type);
    }
    return _parseInitializedIdentifierList(commentAndMetadata,
        modifiers.staticKeyword, _validateModifiersForField(modifiers), type);
  }

  /**
   * Parse a single combinator. Return the combinator that was parsed, or `null`
   * if no combinator is found.
   *
   *     combinator ::=
   *         'show' identifier (',' identifier)*
   *       | 'hide' identifier (',' identifier)*
   */
  Combinator parseCombinator() {
    if (_matchesString(_SHOW) || _matchesString(_HIDE)) {
      Token keyword = getAndAdvance();
      List<SimpleIdentifier> names = _parseIdentifierList();
      if (keyword.lexeme == _SHOW) {
        return new ShowCombinator(keyword, names);
      } else {
        return new HideCombinator(keyword, names);
      }
    }
    return null;
  }

  /**
   * Parse a compilation unit, starting with the given [token]. Return the
   * compilation unit that was parsed.
   */
  CompilationUnit parseCompilationUnit(Token token) {
    _currentToken = token;
    return parseCompilationUnit2();
  }

  /**
   * Parse a compilation unit. Return the compilation unit that was parsed.
   *
   * Specified:
   *
   *     compilationUnit ::=
   *         scriptTag? directive* topLevelDeclaration*
   *
   * Actual:
   *
   *     compilationUnit ::=
   *         scriptTag? topLevelElement*
   *
   *     topLevelElement ::=
   *         directive
   *       | topLevelDeclaration
   */
  CompilationUnit parseCompilationUnit2() {
    Token firstToken = _currentToken;
    ScriptTag scriptTag = null;
    if (_matches(TokenType.SCRIPT_TAG)) {
      scriptTag = new ScriptTag(getAndAdvance());
    }
    //
    // Even though all directives must appear before declarations and must occur
    // in a given order, we allow directives and declarations to occur in any
    // order so that we can recover better.
    //
    bool libraryDirectiveFound = false;
    bool partOfDirectiveFound = false;
    bool partDirectiveFound = false;
    bool directiveFoundAfterDeclaration = false;
    List<Directive> directives = new List<Directive>();
    List<CompilationUnitMember> declarations =
        new List<CompilationUnitMember>();
    Token memberStart = _currentToken;
    while (!_matches(TokenType.EOF)) {
      CommentAndMetadata commentAndMetadata = _parseCommentAndMetadata();
      if ((_matchesKeyword(Keyword.IMPORT) ||
              _matchesKeyword(Keyword.EXPORT) ||
              _matchesKeyword(Keyword.LIBRARY) ||
              _matchesKeyword(Keyword.PART)) &&
          !_tokenMatches(_peek(), TokenType.PERIOD) &&
          !_tokenMatches(_peek(), TokenType.LT) &&
          !_tokenMatches(_peek(), TokenType.OPEN_PAREN)) {
        Directive directive = _parseDirective(commentAndMetadata);
        if (declarations.length > 0 && !directiveFoundAfterDeclaration) {
          _reportErrorForToken(ParserErrorCode.DIRECTIVE_AFTER_DECLARATION,
              directive.beginToken);
          directiveFoundAfterDeclaration = true;
        }
        if (directive is LibraryDirective) {
          if (libraryDirectiveFound) {
            _reportErrorForCurrentToken(
                ParserErrorCode.MULTIPLE_LIBRARY_DIRECTIVES);
          } else {
            if (directives.length > 0) {
              _reportErrorForToken(ParserErrorCode.LIBRARY_DIRECTIVE_NOT_FIRST,
                  directive.libraryKeyword);
            }
            libraryDirectiveFound = true;
          }
        } else if (directive is PartDirective) {
          partDirectiveFound = true;
        } else if (partDirectiveFound) {
          if (directive is ExportDirective) {
            _reportErrorForToken(
                ParserErrorCode.EXPORT_DIRECTIVE_AFTER_PART_DIRECTIVE,
                directive.keyword);
          } else if (directive is ImportDirective) {
            _reportErrorForToken(
                ParserErrorCode.IMPORT_DIRECTIVE_AFTER_PART_DIRECTIVE,
                directive.keyword);
          }
        }
        if (directive is PartOfDirective) {
          if (partOfDirectiveFound) {
            _reportErrorForCurrentToken(
                ParserErrorCode.MULTIPLE_PART_OF_DIRECTIVES);
          } else {
            int directiveCount = directives.length;
            for (int i = 0; i < directiveCount; i++) {
              _reportErrorForToken(
                  ParserErrorCode.NON_PART_OF_DIRECTIVE_IN_PART,
                  directives[i].keyword);
            }
            partOfDirectiveFound = true;
          }
        } else {
          if (partOfDirectiveFound) {
            _reportErrorForToken(ParserErrorCode.NON_PART_OF_DIRECTIVE_IN_PART,
                directive.keyword);
          }
        }
        directives.add(directive);
      } else if (_matches(TokenType.SEMICOLON)) {
        _reportErrorForToken(ParserErrorCode.UNEXPECTED_TOKEN, _currentToken,
            [_currentToken.lexeme]);
        _advance();
      } else {
        CompilationUnitMember member =
            _parseCompilationUnitMember(commentAndMetadata);
        if (member != null) {
          declarations.add(member);
        }
      }
      if (identical(_currentToken, memberStart)) {
        _reportErrorForToken(ParserErrorCode.UNEXPECTED_TOKEN, _currentToken,
            [_currentToken.lexeme]);
        _advance();
        while (!_matches(TokenType.EOF) &&
            !_couldBeStartOfCompilationUnitMember()) {
          _advance();
        }
      }
      memberStart = _currentToken;
    }
    return new CompilationUnit(
        firstToken, scriptTag, directives, declarations, _currentToken);
  }

  /**
   * Parse a conditional expression. Return the conditional expression that was
   * parsed.
   *
   *     conditionalExpression ::=
   *         ifNullExpression ('?' expressionWithoutCascade ':' expressionWithoutCascade)?
   */
  Expression parseConditionalExpression() {
    Expression condition = parseIfNullExpression();
    if (!_matches(TokenType.QUESTION)) {
      return condition;
    }
    Token question = getAndAdvance();
    Expression thenExpression = parseExpressionWithoutCascade();
    Token colon = _expect(TokenType.COLON);
    Expression elseExpression = parseExpressionWithoutCascade();
    return new ConditionalExpression(
        condition, question, thenExpression, colon, elseExpression);
  }

  /**
   * Parse the name of a constructor. Return the constructor name that was
   * parsed.
   *
   *     constructorName:
   *         type ('.' identifier)?
   */
  ConstructorName parseConstructorName() {
    TypeName type = parseTypeName();
    Token period = null;
    SimpleIdentifier name = null;
    if (_matches(TokenType.PERIOD)) {
      period = getAndAdvance();
      name = parseSimpleIdentifier();
    }
    return new ConstructorName(type, period, name);
  }

  /**
   * Parse the script tag and directives in a compilation unit, starting with
   * the given [token], until the first non-directive is encountered. The
   * remainder of the compilation unit will not be parsed. Specifically, if
   * there are directives later in the file, they will not be parsed. Return the
   * compilation unit that was parsed.
   */
  CompilationUnit parseDirectives(Token token) {
    _currentToken = token;
    return _parseDirectives();
  }

  /**
   * Parse an expression, starting with the given [token]. Return the expression
   * that was parsed, or `null` if the tokens do not represent a recognizable
   * expression.
   */
  Expression parseExpression(Token token) {
    _currentToken = token;
    return parseExpression2();
  }

  /**
   * Parse an expression that might contain a cascade. Return the expression
   * that was parsed.
   *
   *     expression ::=
   *         assignableExpression assignmentOperator expression
   *       | conditionalExpression cascadeSection*
   *       | throwExpression
   */
  Expression parseExpression2() {
    if (_matchesKeyword(Keyword.THROW)) {
      return _parseThrowExpression();
    } else if (_matchesKeyword(Keyword.RETHROW)) {
      // TODO(brianwilkerson) Rethrow is a statement again.
      return _parseRethrowExpression();
    }
    //
    // assignableExpression is a subset of conditionalExpression, so we can
    // parse a conditional expression and then determine whether it is followed
    // by an assignmentOperator, checking for conformance to the restricted
    // grammar after making that determination.
    //
    Expression expression = parseConditionalExpression();
    TokenType tokenType = _currentToken.type;
    if (tokenType == TokenType.PERIOD_PERIOD) {
      List<Expression> cascadeSections = new List<Expression>();
      while (tokenType == TokenType.PERIOD_PERIOD) {
        Expression section = _parseCascadeSection();
        if (section != null) {
          cascadeSections.add(section);
        }
        tokenType = _currentToken.type;
      }
      return new CascadeExpression(expression, cascadeSections);
    } else if (tokenType.isAssignmentOperator) {
      Token operator = getAndAdvance();
      _ensureAssignable(expression);
      return new AssignmentExpression(expression, operator, parseExpression2());
    }
    return expression;
  }

  /**
   * Parse an expression that does not contain any cascades. Return the
   * expression that was parsed.
   *
   *     expressionWithoutCascade ::=
   *         assignableExpression assignmentOperator expressionWithoutCascade
   *       | conditionalExpression
   *       | throwExpressionWithoutCascade
   */
  Expression parseExpressionWithoutCascade() {
    if (_matchesKeyword(Keyword.THROW)) {
      return _parseThrowExpressionWithoutCascade();
    } else if (_matchesKeyword(Keyword.RETHROW)) {
      return _parseRethrowExpression();
    }
    //
    // assignableExpression is a subset of conditionalExpression, so we can
    // parse a conditional expression and then determine whether it is followed
    // by an assignmentOperator, checking for conformance to the restricted
    // grammar after making that determination.
    //
    Expression expression = parseConditionalExpression();
    if (_currentToken.type.isAssignmentOperator) {
      Token operator = getAndAdvance();
      _ensureAssignable(expression);
      expression = new AssignmentExpression(
          expression, operator, parseExpressionWithoutCascade());
    }
    return expression;
  }

  /**
   * Parse a class extends clause. Return the class extends clause that was
   * parsed.
   *
   *     classExtendsClause ::=
   *         'extends' type
   */
  ExtendsClause parseExtendsClause() {
    Token keyword = _expectKeyword(Keyword.EXTENDS);
    TypeName superclass = parseTypeName();
    return new ExtendsClause(keyword, superclass);
  }

  /**
   * Parse a list of formal parameters. Return the formal parameters that were
   * parsed.
   *
   *     formalParameterList ::=
   *         '(' ')'
   *       | '(' normalFormalParameters (',' optionalFormalParameters)? ')'
   *       | '(' optionalFormalParameters ')'
   *
   *     normalFormalParameters ::=
   *         normalFormalParameter (',' normalFormalParameter)*
   *
   *     optionalFormalParameters ::=
   *         optionalPositionalFormalParameters
   *       | namedFormalParameters
   *
   *     optionalPositionalFormalParameters ::=
   *         '[' defaultFormalParameter (',' defaultFormalParameter)* ']'
   *
   *     namedFormalParameters ::=
   *         '{' defaultNamedParameter (',' defaultNamedParameter)* '}'
   */
  FormalParameterList parseFormalParameterList() {
    Token leftParenthesis = _expect(TokenType.OPEN_PAREN);
    if (_matches(TokenType.CLOSE_PAREN)) {
      return new FormalParameterList(
          leftParenthesis, null, null, null, getAndAdvance());
    }
    //
    // Even though it is invalid to have default parameters outside of brackets,
    // required parameters inside of brackets, or multiple groups of default and
    // named parameters, we allow all of these cases so that we can recover
    // better.
    //
    List<FormalParameter> parameters = new List<FormalParameter>();
    List<FormalParameter> normalParameters = new List<FormalParameter>();
    List<FormalParameter> positionalParameters = new List<FormalParameter>();
    List<FormalParameter> namedParameters = new List<FormalParameter>();
    List<FormalParameter> currentParameters = normalParameters;
    Token leftSquareBracket = null;
    Token rightSquareBracket = null;
    Token leftCurlyBracket = null;
    Token rightCurlyBracket = null;
    ParameterKind kind = ParameterKind.REQUIRED;
    bool firstParameter = true;
    bool reportedMuliplePositionalGroups = false;
    bool reportedMulipleNamedGroups = false;
    bool reportedMixedGroups = false;
    bool wasOptionalParameter = false;
    Token initialToken = null;
    do {
      if (firstParameter) {
        firstParameter = false;
      } else if (!_optional(TokenType.COMMA)) {
        // TODO(brianwilkerson) The token is wrong, we need to recover from this
        // case.
        if (_getEndToken(leftParenthesis) != null) {
          _reportErrorForCurrentToken(
              ParserErrorCode.EXPECTED_TOKEN, [TokenType.COMMA.lexeme]);
        } else {
          _reportErrorForToken(ParserErrorCode.MISSING_CLOSING_PARENTHESIS,
              _currentToken.previous);
          break;
        }
      }
      initialToken = _currentToken;
      //
      // Handle the beginning of parameter groups.
      //
      if (_matches(TokenType.OPEN_SQUARE_BRACKET)) {
        wasOptionalParameter = true;
        if (leftSquareBracket != null && !reportedMuliplePositionalGroups) {
          _reportErrorForCurrentToken(
              ParserErrorCode.MULTIPLE_POSITIONAL_PARAMETER_GROUPS);
          reportedMuliplePositionalGroups = true;
        }
        if (leftCurlyBracket != null && !reportedMixedGroups) {
          _reportErrorForCurrentToken(ParserErrorCode.MIXED_PARAMETER_GROUPS);
          reportedMixedGroups = true;
        }
        leftSquareBracket = getAndAdvance();
        currentParameters = positionalParameters;
        kind = ParameterKind.POSITIONAL;
      } else if (_matches(TokenType.OPEN_CURLY_BRACKET)) {
        wasOptionalParameter = true;
        if (leftCurlyBracket != null && !reportedMulipleNamedGroups) {
          _reportErrorForCurrentToken(
              ParserErrorCode.MULTIPLE_NAMED_PARAMETER_GROUPS);
          reportedMulipleNamedGroups = true;
        }
        if (leftSquareBracket != null && !reportedMixedGroups) {
          _reportErrorForCurrentToken(ParserErrorCode.MIXED_PARAMETER_GROUPS);
          reportedMixedGroups = true;
        }
        leftCurlyBracket = getAndAdvance();
        currentParameters = namedParameters;
        kind = ParameterKind.NAMED;
      }
      //
      // Parse and record the parameter.
      //
      FormalParameter parameter = _parseFormalParameter(kind);
      parameters.add(parameter);
      currentParameters.add(parameter);
      if (kind == ParameterKind.REQUIRED && wasOptionalParameter) {
        _reportErrorForNode(
            ParserErrorCode.NORMAL_BEFORE_OPTIONAL_PARAMETERS, parameter);
      }
      //
      // Handle the end of parameter groups.
      //
      // TODO(brianwilkerson) Improve the detection and reporting of missing and
      // mismatched delimiters.
      if (_matches(TokenType.CLOSE_SQUARE_BRACKET)) {
        rightSquareBracket = getAndAdvance();
        currentParameters = normalParameters;
        if (leftSquareBracket == null) {
          if (leftCurlyBracket != null) {
            _reportErrorForCurrentToken(
                ParserErrorCode.WRONG_TERMINATOR_FOR_PARAMETER_GROUP, ["}"]);
            rightCurlyBracket = rightSquareBracket;
            rightSquareBracket = null;
          } else {
            _reportErrorForCurrentToken(
                ParserErrorCode.UNEXPECTED_TERMINATOR_FOR_PARAMETER_GROUP,
                ["["]);
          }
        }
        kind = ParameterKind.REQUIRED;
      } else if (_matches(TokenType.CLOSE_CURLY_BRACKET)) {
        rightCurlyBracket = getAndAdvance();
        currentParameters = normalParameters;
        if (leftCurlyBracket == null) {
          if (leftSquareBracket != null) {
            _reportErrorForCurrentToken(
                ParserErrorCode.WRONG_TERMINATOR_FOR_PARAMETER_GROUP, ["]"]);
            rightSquareBracket = rightCurlyBracket;
            rightCurlyBracket = null;
          } else {
            _reportErrorForCurrentToken(
                ParserErrorCode.UNEXPECTED_TERMINATOR_FOR_PARAMETER_GROUP,
                ["{"]);
          }
        }
        kind = ParameterKind.REQUIRED;
      }
    } while (!_matches(TokenType.CLOSE_PAREN) &&
        !identical(initialToken, _currentToken));
    Token rightParenthesis = _expect(TokenType.CLOSE_PAREN);
    //
    // Check that the groups were closed correctly.
    //
    if (leftSquareBracket != null && rightSquareBracket == null) {
      _reportErrorForCurrentToken(
          ParserErrorCode.MISSING_TERMINATOR_FOR_PARAMETER_GROUP, ["]"]);
    }
    if (leftCurlyBracket != null && rightCurlyBracket == null) {
      _reportErrorForCurrentToken(
          ParserErrorCode.MISSING_TERMINATOR_FOR_PARAMETER_GROUP, ["}"]);
    }
    //
    // Build the parameter list.
    //
    if (leftSquareBracket == null) {
      leftSquareBracket = leftCurlyBracket;
    }
    if (rightSquareBracket == null) {
      rightSquareBracket = rightCurlyBracket;
    }
    return new FormalParameterList(leftParenthesis, parameters,
        leftSquareBracket, rightSquareBracket, rightParenthesis);
  }

  /**
   * Parse a function expression. Return the function expression that was
   * parsed.
   *
   *     functionExpression ::=
   *         typeParameters? formalParameterList functionExpressionBody
   */
  FunctionExpression parseFunctionExpression() {
    TypeParameterList typeParameters = null;
    if (parseGenericMethods && _matches(TokenType.LT)) {
      typeParameters = parseTypeParameterList();
    }
    FormalParameterList parameters = parseFormalParameterList();
    _validateFormalParameterList(parameters);
    FunctionBody body =
        _parseFunctionBody(false, ParserErrorCode.MISSING_FUNCTION_BODY, true);
    return new FunctionExpression(typeParameters, parameters, body);
  }

  /**
   * Parse an if-null expression.  Return the if-null expression that was
   * parsed.
   *
   *     ifNullExpression ::= logicalOrExpression ('??' logicalOrExpression)*
   */
  Expression parseIfNullExpression() {
    Expression expression = parseLogicalOrExpression();
    while (_matches(TokenType.QUESTION_QUESTION)) {
      Token operator = getAndAdvance();
      expression = new BinaryExpression(
          expression, operator, parseLogicalOrExpression());
    }
    return expression;
  }

  /**
   * Parse an implements clause. Return the implements clause that was parsed.
   *
   *     implementsClause ::=
   *         'implements' type (',' type)*
   */
  ImplementsClause parseImplementsClause() {
    Token keyword = _expectKeyword(Keyword.IMPLEMENTS);
    List<TypeName> interfaces = new List<TypeName>();
    interfaces.add(parseTypeName());
    while (_optional(TokenType.COMMA)) {
      interfaces.add(parseTypeName());
    }
    return new ImplementsClause(keyword, interfaces);
  }

  /**
   * Parse a label. Return the label that was parsed.
   *
   *     label ::=
   *         identifier ':'
   */
  Label parseLabel() {
    SimpleIdentifier label = parseSimpleIdentifier();
    Token colon = _expect(TokenType.COLON);
    return new Label(label, colon);
  }

  /**
   * Parse a library identifier. Return the library identifier that was parsed.
   *
   *     libraryIdentifier ::=
   *         identifier ('.' identifier)*
   */
  LibraryIdentifier parseLibraryIdentifier() {
    List<SimpleIdentifier> components = new List<SimpleIdentifier>();
    components.add(parseSimpleIdentifier());
    while (_matches(TokenType.PERIOD)) {
      _advance();
      components.add(parseSimpleIdentifier());
    }
    return new LibraryIdentifier(components);
  }

  /**
   * Parse a logical or expression. Return the logical or expression that was
   * parsed.
   *
   *     logicalOrExpression ::=
   *         logicalAndExpression ('||' logicalAndExpression)*
   */
  Expression parseLogicalOrExpression() {
    Expression expression = _parseLogicalAndExpression();
    while (_matches(TokenType.BAR_BAR)) {
      Token operator = getAndAdvance();
      expression = new BinaryExpression(
          expression, operator, _parseLogicalAndExpression());
    }
    return expression;
  }

  /**
   * Parse a map literal entry. Return the map literal entry that was parsed.
   *
   *     mapLiteralEntry ::=
   *         expression ':' expression
   */
  MapLiteralEntry parseMapLiteralEntry() {
    Expression key = parseExpression2();
    Token separator = _expect(TokenType.COLON);
    Expression value = parseExpression2();
    return new MapLiteralEntry(key, separator, value);
  }

  /**
   * Parse a normal formal parameter. Return the normal formal parameter that
   * was parsed.
   *
   *     normalFormalParameter ::=
   *         functionSignature
   *       | fieldFormalParameter
   *       | simpleFormalParameter
   *
   *     functionSignature:
   *         metadata returnType? identifier typeParameters? formalParameterList
   *
   *     fieldFormalParameter ::=
   *         metadata finalConstVarOrType? 'this' '.' identifier
   *
   *     simpleFormalParameter ::=
   *         declaredIdentifier
   *       | metadata identifier
   */
  NormalFormalParameter parseNormalFormalParameter() {
    CommentAndMetadata commentAndMetadata = _parseCommentAndMetadata();
    FinalConstVarOrType holder = _parseFinalConstVarOrType(true);
    Token thisKeyword = null;
    Token period = null;
    if (_matchesKeyword(Keyword.THIS)) {
      thisKeyword = getAndAdvance();
      period = _expect(TokenType.PERIOD);
    }
    SimpleIdentifier identifier = parseSimpleIdentifier();
    TypeParameterList typeParameters = null;
    if (parseGenericMethods && _matches(TokenType.LT)) {
      typeParameters = parseTypeParameterList();
    }
    if (_matches(TokenType.OPEN_PAREN)) {
      FormalParameterList parameters = parseFormalParameterList();
      if (thisKeyword == null) {
        if (holder.keyword != null) {
          _reportErrorForToken(
              ParserErrorCode.FUNCTION_TYPED_PARAMETER_VAR, holder.keyword);
        }
        return new FunctionTypedFormalParameter(commentAndMetadata.comment,
            commentAndMetadata.metadata, holder.type, identifier,
            typeParameters, parameters);
      } else {
        return new FieldFormalParameter(commentAndMetadata.comment,
            commentAndMetadata.metadata, holder.keyword, holder.type,
            thisKeyword, period, identifier, typeParameters, parameters);
      }
    } else if (typeParameters != null) {
      // TODO(brianwilkerson) Report an error. It looks like a function-typed
      // parameter with no parameter list.
      //_reportErrorForToken(ParserErrorCode.MISSING_PARAMETERS, typeParameters.endToken);
    }
    TypeName type = holder.type;
    if (type != null) {
      if (_tokenMatchesKeyword(type.name.beginToken, Keyword.VOID)) {
        _reportErrorForToken(
            ParserErrorCode.VOID_PARAMETER, type.name.beginToken);
      } else if (holder.keyword != null &&
          _tokenMatchesKeyword(holder.keyword, Keyword.VAR)) {
        _reportErrorForToken(ParserErrorCode.VAR_AND_TYPE, holder.keyword);
      }
    }
    if (thisKeyword != null) {
      // TODO(brianwilkerson) If there are type parameters but no parameters,
      // should we create a synthetic empty parameter list here so we can
      // capture the type parameters?
      return new FieldFormalParameter(commentAndMetadata.comment,
          commentAndMetadata.metadata, holder.keyword, holder.type, thisKeyword,
          period, identifier, null, null);
    }
    return new SimpleFormalParameter(commentAndMetadata.comment,
        commentAndMetadata.metadata, holder.keyword, holder.type, identifier);
  }

  /**
   * Parse a prefixed identifier. Return the prefixed identifier that was
   * parsed.
   *
   *     prefixedIdentifier ::=
   *         identifier ('.' identifier)?
   */
  Identifier parsePrefixedIdentifier() {
    SimpleIdentifier qualifier = parseSimpleIdentifier();
    if (!_matches(TokenType.PERIOD)) {
      return qualifier;
    }
    Token period = getAndAdvance();
    SimpleIdentifier qualified = parseSimpleIdentifier();
    return new PrefixedIdentifier(qualifier, period, qualified);
  }

  /**
   * Parse a return type. Return the return type that was parsed.
   *
   *     returnType ::=
   *         'void'
   *       | type
   */
  TypeName parseReturnType() {
    if (_matchesKeyword(Keyword.VOID)) {
      return new TypeName(new SimpleIdentifier(getAndAdvance()), null);
    } else {
      return parseTypeName();
    }
  }

  /**
   * Parse a simple identifier. Return the simple identifier that was parsed.
   *
   *     identifier ::=
   *         IDENTIFIER
   */
  SimpleIdentifier parseSimpleIdentifier() {
    if (_matchesIdentifier()) {
      String lexeme = _currentToken.lexeme;
      if ((_inAsync || _inGenerator) &&
          (lexeme == 'async' || lexeme == 'await' || lexeme == 'yield')) {
        _reportErrorForCurrentToken(
            ParserErrorCode.ASYNC_KEYWORD_USED_AS_IDENTIFIER);
      }
      return new SimpleIdentifier(getAndAdvance());
    }
    _reportErrorForCurrentToken(ParserErrorCode.MISSING_IDENTIFIER);
    return _createSyntheticIdentifier();
  }

  /**
   * Parse a statement, starting with the given [token]. Return the statement
   * that was parsed, or `null` if the tokens do not represent a recognizable
   * statement.
   */
  Statement parseStatement(Token token) {
    _currentToken = token;
    return parseStatement2();
  }

  /**
   * Parse a statement. Return the statement that was parsed.
   *
   *     statement ::=
   *         label* nonLabeledStatement
   */
  Statement parseStatement2() {
    List<Label> labels = new List<Label>();
    while (_matchesIdentifier() && _tokenMatches(_peek(), TokenType.COLON)) {
      labels.add(parseLabel());
    }
    Statement statement = _parseNonLabeledStatement();
    if (labels.isEmpty) {
      return statement;
    }
    return new LabeledStatement(labels, statement);
  }

  /**
   * Parse a sequence of statements, starting with the given [token]. Return the
   * statements that were parsed, or `null` if the tokens do not represent a
   * recognizable sequence of statements.
   */
  List<Statement> parseStatements(Token token) {
    _currentToken = token;
    return _parseStatementList();
  }

  /**
   * Parse a string literal. Return the string literal that was parsed.
   *
   *     stringLiteral ::=
   *         MULTI_LINE_STRING+
   *       | SINGLE_LINE_STRING+
   */
  StringLiteral parseStringLiteral() {
    List<StringLiteral> strings = new List<StringLiteral>();
    while (_matches(TokenType.STRING)) {
      Token string = getAndAdvance();
      if (_matches(TokenType.STRING_INTERPOLATION_EXPRESSION) ||
          _matches(TokenType.STRING_INTERPOLATION_IDENTIFIER)) {
        strings.add(_parseStringInterpolation(string));
      } else {
        strings.add(new SimpleStringLiteral(
            string, _computeStringValue(string.lexeme, true, true)));
      }
    }
    if (strings.length < 1) {
      _reportErrorForCurrentToken(ParserErrorCode.EXPECTED_STRING_LITERAL);
      return _createSyntheticStringLiteral();
    } else if (strings.length == 1) {
      return strings[0];
    } else {
      return new AdjacentStrings(strings);
    }
  }

  /**
   * Parse a list of type arguments. Return the type argument list that was
   * parsed.
   *
   *     typeArguments ::=
   *         '<' typeList '>'
   *
   *     typeList ::=
   *         type (',' type)*
   */
  TypeArgumentList parseTypeArgumentList() {
    Token leftBracket = _expect(TokenType.LT);
    List<TypeName> arguments = new List<TypeName>();
    arguments.add(parseTypeName());
    while (_optional(TokenType.COMMA)) {
      arguments.add(parseTypeName());
    }
    Token rightBracket = _expectGt();
    return new TypeArgumentList(leftBracket, arguments, rightBracket);
  }

  /**
   * Parse a type name. Return the type name that was parsed.
   *
   *     type ::=
   *         qualified typeArguments?
   */
  TypeName parseTypeName() {
    Identifier typeName;
    if (_matchesKeyword(Keyword.VAR)) {
      _reportErrorForCurrentToken(ParserErrorCode.VAR_AS_TYPE_NAME);
      typeName = new SimpleIdentifier(getAndAdvance());
    } else if (_matchesIdentifier()) {
      typeName = parsePrefixedIdentifier();
    } else {
      typeName = _createSyntheticIdentifier();
      _reportErrorForCurrentToken(ParserErrorCode.EXPECTED_TYPE_NAME);
    }
    TypeArgumentList typeArguments = null;
    if (_matches(TokenType.LT)) {
      typeArguments = parseTypeArgumentList();
    }
    return new TypeName(typeName, typeArguments);
  }

  /**
   * Parse a type parameter. Return the type parameter that was parsed.
   *
   *     typeParameter ::=
   *         metadata name ('extends' bound)?
   */
  TypeParameter parseTypeParameter() {
    CommentAndMetadata commentAndMetadata = _parseCommentAndMetadata();
    SimpleIdentifier name = parseSimpleIdentifier();
    if (_matchesKeyword(Keyword.EXTENDS)) {
      Token keyword = getAndAdvance();
      TypeName bound = parseTypeName();
      return new TypeParameter(commentAndMetadata.comment,
          commentAndMetadata.metadata, name, keyword, bound);
    }
    return new TypeParameter(commentAndMetadata.comment,
        commentAndMetadata.metadata, name, null, null);
  }

  /**
   * Parse a list of type parameters. Return the list of type parameters that
   * were parsed.
   *
   *     typeParameterList ::=
   *         '<' typeParameter (',' typeParameter)* '>'
   */
  TypeParameterList parseTypeParameterList() {
    Token leftBracket = _expect(TokenType.LT);
    List<TypeParameter> typeParameters = new List<TypeParameter>();
    typeParameters.add(parseTypeParameter());
    while (_optional(TokenType.COMMA)) {
      typeParameters.add(parseTypeParameter());
    }
    Token rightBracket = _expectGt();
    return new TypeParameterList(leftBracket, typeParameters, rightBracket);
  }

  /**
   * Parse a with clause. Return the with clause that was parsed.
   *
   *     withClause ::=
   *         'with' typeName (',' typeName)*
   */
  WithClause parseWithClause() {
    Token with2 = _expectKeyword(Keyword.WITH);
    List<TypeName> types = new List<TypeName>();
    types.add(parseTypeName());
    while (_optional(TokenType.COMMA)) {
      types.add(parseTypeName());
    }
    return new WithClause(with2, types);
  }

  /**
   * Advance to the next token in the token stream.
   */
  void _advance() {
    _currentToken = _currentToken.next;
  }

  /**
   * Append the character equivalent of the given [scalarValue] to the given
   * [builder]. Use the [startIndex] and [endIndex] to report an error, and
   * don't append anything to the builder, if the scalar value is invalid. The
   * [escapeSequence] is the escape sequence that was parsed to produce the
   * scalar value (used for error reporting).
   */
  void _appendScalarValue(StringBuffer buffer, String escapeSequence,
      int scalarValue, int startIndex, int endIndex) {
    if (scalarValue < 0 ||
        scalarValue > Character.MAX_CODE_POINT ||
        (scalarValue >= 0xD800 && scalarValue <= 0xDFFF)) {
      _reportErrorForCurrentToken(
          ParserErrorCode.INVALID_CODE_POINT, [escapeSequence]);
      return;
    }
    if (scalarValue < Character.MAX_VALUE) {
      buffer.writeCharCode(scalarValue);
    } else {
      buffer.write(Character.toChars(scalarValue));
    }
  }

  /**
   * Return the content of a string with the given literal representation. The
   * [lexeme] is the literal representation of the string. The flag [isFirst] is
   * `true` if this is the first token in a string literal. The flag [isLast] is
   * `true` if this is the last token in a string literal.
   */
  String _computeStringValue(String lexeme, bool isFirst, bool isLast) {
    StringLexemeHelper helper = new StringLexemeHelper(lexeme, isFirst, isLast);
    int start = helper.start;
    int end = helper.end;
    bool stringEndsAfterStart = end >= start;
    assert(stringEndsAfterStart);
    if (!stringEndsAfterStart) {
      AnalysisEngine.instance.logger.logError(
          "Internal error: computeStringValue($lexeme, $isFirst, $isLast)");
      return "";
    }
    if (helper.isRaw) {
      return lexeme.substring(start, end);
    }
    StringBuffer buffer = new StringBuffer();
    int index = start;
    while (index < end) {
      index = _translateCharacter(buffer, lexeme, index);
    }
    return buffer.toString();
  }

  /**
   * Convert the given [method] declaration into the nearest valid top-level
   * function declaration (that is, the function declaration that most closely
   * captures the components of the given method declaration).
   */
  FunctionDeclaration _convertToFunctionDeclaration(MethodDeclaration method) =>
      new FunctionDeclaration(method.documentationComment, method.metadata,
          method.externalKeyword, method.returnType, method.propertyKeyword,
          method.name, new FunctionExpression(
              method.typeParameters, method.parameters, method.body));

  /**
   * Return `true` if the current token could be the start of a compilation unit
   * member. This method is used for recovery purposes to decide when to stop
   * skipping tokens after finding an error while parsing a compilation unit
   * member.
   */
  bool _couldBeStartOfCompilationUnitMember() {
    if ((_matchesKeyword(Keyword.IMPORT) ||
            _matchesKeyword(Keyword.EXPORT) ||
            _matchesKeyword(Keyword.LIBRARY) ||
            _matchesKeyword(Keyword.PART)) &&
        !_tokenMatches(_peek(), TokenType.PERIOD) &&
        !_tokenMatches(_peek(), TokenType.LT)) {
      // This looks like the start of a directive
      return true;
    } else if (_matchesKeyword(Keyword.CLASS)) {
      // This looks like the start of a class definition
      return true;
    } else if (_matchesKeyword(Keyword.TYPEDEF) &&
        !_tokenMatches(_peek(), TokenType.PERIOD) &&
        !_tokenMatches(_peek(), TokenType.LT)) {
      // This looks like the start of a typedef
      return true;
    } else if (_matchesKeyword(Keyword.VOID) ||
        ((_matchesKeyword(Keyword.GET) || _matchesKeyword(Keyword.SET)) &&
            _tokenMatchesIdentifier(_peek())) ||
        (_matchesKeyword(Keyword.OPERATOR) && _isOperator(_peek()))) {
      // This looks like the start of a function
      return true;
    } else if (_matchesIdentifier()) {
      if (_tokenMatches(_peek(), TokenType.OPEN_PAREN)) {
        // This looks like the start of a function
        return true;
      }
      Token token = _skipReturnType(_currentToken);
      if (token == null) {
        return false;
      }
      if (_matchesKeyword(Keyword.GET) ||
          _matchesKeyword(Keyword.SET) ||
          (_matchesKeyword(Keyword.OPERATOR) && _isOperator(_peek())) ||
          _matchesIdentifier()) {
        return true;
      }
    }
    return false;
  }

  /**
   * Return a synthetic identifier.
   */
  SimpleIdentifier _createSyntheticIdentifier() {
    Token syntheticToken;
    if (_currentToken.type == TokenType.KEYWORD) {
      // Consider current keyword token as an identifier.
      // It is not always true, e.g. "^is T" where "^" is place the place for
      // synthetic identifier. By creating SyntheticStringToken we can
      // distinguish a real identifier from synthetic. In the code completion
      // behavior will depend on a cursor position - before or on "is".
      syntheticToken = _injectToken(new SyntheticStringToken(
          TokenType.IDENTIFIER, _currentToken.lexeme, _currentToken.offset));
    } else {
      syntheticToken = _createSyntheticToken(TokenType.IDENTIFIER);
    }
    return new SimpleIdentifier(syntheticToken);
  }

  /**
   * Return a synthetic token representing the given [keyword].
   */
  Token _createSyntheticKeyword(Keyword keyword) => _injectToken(
      new Parser_SyntheticKeywordToken(keyword, _currentToken.offset));

  /**
   * Return a synthetic string literal.
   */
  SimpleStringLiteral _createSyntheticStringLiteral() =>
      new SimpleStringLiteral(_createSyntheticToken(TokenType.STRING), "");

  /**
   * Return a synthetic token with the given [type].
   */
  Token _createSyntheticToken(TokenType type) =>
      _injectToken(new StringToken(type, "", _currentToken.offset));

  /**
   * Create and return a new token with the given [type]. The token will replace
   * the first portion of the given [token], so it will have the same offset and
   * will have any comments that might have preceeded the token.
   */
  Token _createToken(Token token, TokenType type, {bool isBegin: false}) {
    CommentToken comments = token.precedingComments;
    if (comments == null) {
      if (isBegin) {
        return new BeginToken(type, token.offset);
      }
      return new Token(type, token.offset);
    } else if (isBegin) {
      return new BeginTokenWithComment(type, token.offset, comments);
    }
    return new TokenWithComment(type, token.offset, comments);
  }

  /**
   * Check that the given [expression] is assignable and report an error if it
   * isn't.
   *
   *     assignableExpression ::=
   *         primary (arguments* assignableSelector)+
   *       | 'super' unconditionalAssignableSelector
   *       | identifier
   *
   *     unconditionalAssignableSelector ::=
   *         '[' expression ']'
   *       | '.' identifier
   *
   *     assignableSelector ::=
   *         unconditionalAssignableSelector
   *       | '?.' identifier
   */
  void _ensureAssignable(Expression expression) {
    if (expression != null && !expression.isAssignable) {
      _reportErrorForCurrentToken(
          ParserErrorCode.ILLEGAL_ASSIGNMENT_TO_NON_ASSIGNABLE);
    }
  }

  /**
   * If the current token has the expected type, return it after advancing to
   * the next token. Otherwise report an error and return the current token
   * without advancing.
   *
   * Note that the method [_expectGt] should be used if the argument to this
   * method would be [TokenType.GT].
   *
   * The [type] is the type of token that is expected.
   */
  Token _expect(TokenType type) {
    if (_matches(type)) {
      return getAndAdvance();
    }
    // Remove uses of this method in favor of matches?
    // Pass in the error code to use to report the error?
    if (type == TokenType.SEMICOLON) {
      if (_tokenMatches(_currentToken.next, TokenType.SEMICOLON)) {
        _reportErrorForCurrentToken(
            ParserErrorCode.UNEXPECTED_TOKEN, [_currentToken.lexeme]);
        _advance();
        return getAndAdvance();
      }
      _reportErrorForToken(ParserErrorCode.EXPECTED_TOKEN,
          _currentToken.previous, [type.lexeme]);
    } else {
      _reportErrorForCurrentToken(
          ParserErrorCode.EXPECTED_TOKEN, [type.lexeme]);
    }
    return _currentToken;
  }

  /**
   * If the current token has the type [TokenType.GT], return it after advancing
   * to the next token. Otherwise report an error and return the current token
   * without advancing.
   */
  Token _expectGt() {
    if (_matchesGt()) {
      return getAndAdvance();
    }
    _reportErrorForCurrentToken(
        ParserErrorCode.EXPECTED_TOKEN, [TokenType.GT.lexeme]);
    return _currentToken;
  }

  /**
   * If the current token is a keyword matching the given [keyword], return it
   * after advancing to the next token. Otherwise report an error and return the
   * current token without advancing.
   */
  Token _expectKeyword(Keyword keyword) {
    if (_matchesKeyword(keyword)) {
      return getAndAdvance();
    }
    // Remove uses of this method in favor of matches?
    // Pass in the error code to use to report the error?
    _reportErrorForCurrentToken(
        ParserErrorCode.EXPECTED_TOKEN, [keyword.syntax]);
    return _currentToken;
  }

  /**
   * If the current token is a semicolon, return it after advancing to the next
   * token. Otherwise report an error and create a synthetic semicolon.
   */
  Token _expectSemicolon() {
    // TODO(scheglov) consider pushing this behavior into [_expect]
    if (_matches(TokenType.SEMICOLON)) {
      return getAndAdvance();
    } else {
      _reportErrorForToken(
          ParserErrorCode.EXPECTED_TOKEN, _currentToken.previous, [";"]);
      return _createSyntheticToken(TokenType.SEMICOLON);
    }
  }

  /**
   * Search the given list of [ranges] for a range that contains the given
   * [index]. Return the range that was found, or `null` if none of the ranges
   * contain the index.
   */
  List<int> _findRange(List<List<int>> ranges, int index) {
    int rangeCount = ranges.length;
    for (int i = 0; i < rangeCount; i++) {
      List<int> range = ranges[i];
      if (range[0] <= index && index <= range[1]) {
        return range;
      } else if (index < range[0]) {
        return null;
      }
    }
    return null;
  }

  /**
   * Return a list of the ranges of characters in the given [comment] that
   * should be treated as code blocks.
   */
  List<List<int>> _getCodeBlockRanges(String comment) {
    List<List<int>> ranges = new List<List<int>>();
    int length = comment.length;
    if (length < 3) {
      return ranges;
    }
    int index = 0;
    int firstChar = comment.codeUnitAt(0);
    if (firstChar == 0x2F) {
      int secondChar = comment.codeUnitAt(1);
      int thirdChar = comment.codeUnitAt(2);
      if ((secondChar == 0x2A && thirdChar == 0x2A) ||
          (secondChar == 0x2F && thirdChar == 0x2F)) {
        index = 3;
      }
    }
    while (index < length) {
      int currentChar = comment.codeUnitAt(index);
      if (currentChar == 0xD || currentChar == 0xA) {
        index = index + 1;
        while (index < length &&
            Character.isWhitespace(comment.codeUnitAt(index))) {
          index = index + 1;
        }
        if (StringUtilities.startsWith6(
            comment, index, 0x2A, 0x20, 0x20, 0x20, 0x20, 0x20)) {
          int end = index + 6;
          while (end < length &&
              comment.codeUnitAt(end) != 0xD &&
              comment.codeUnitAt(end) != 0xA) {
            end = end + 1;
          }
          ranges.add(<int>[index, end]);
          index = end;
        }
      } else if (index + 1 < length &&
          currentChar == 0x5B &&
          comment.codeUnitAt(index + 1) == 0x3A) {
        int end = StringUtilities.indexOf2(comment, index + 2, 0x3A, 0x5D);
        if (end < 0) {
          end = length;
        }
        ranges.add(<int>[index, end]);
        index = end + 1;
      } else {
        index = index + 1;
      }
    }
    return ranges;
  }

  /**
   * Return the end token associated with the given [beginToken], or `null` if
   * either the given token is not a begin token or it does not have an end
   * token associated with it.
   */
  Token _getEndToken(Token beginToken) {
    if (beginToken is BeginToken) {
      return beginToken.endToken;
    }
    return null;
  }

  /**
   * Inject the given [token] into the token stream immediately before the
   * current token.
   */
  Token _injectToken(Token token) {
    Token previous = _currentToken.previous;
    token.setNext(_currentToken);
    previous.setNext(token);
    return token;
  }

  /**
   * Return `true` if the current token appears to be the beginning of a
   * function declaration.
   */
  bool _isFunctionDeclaration() {
    if (_matchesKeyword(Keyword.VOID)) {
      return true;
    }
    Token afterReturnType = _skipTypeName(_currentToken);
    if (afterReturnType == null) {
      // There was no return type, but it is optional, so go back to where we
      // started.
      afterReturnType = _currentToken;
    }
    Token afterIdentifier = _skipSimpleIdentifier(afterReturnType);
    if (afterIdentifier == null) {
      // It's possible that we parsed the function name as if it were a type
      // name, so see whether it makes sense if we assume that there is no type.
      afterIdentifier = _skipSimpleIdentifier(_currentToken);
    }
    if (afterIdentifier == null) {
      return false;
    }
    if (_isFunctionExpression(afterIdentifier)) {
      return true;
    }
    // It's possible that we have found a getter. While this isn't valid at this
    // point we test for it in order to recover better.
    if (_matchesKeyword(Keyword.GET)) {
      Token afterName = _skipSimpleIdentifier(_currentToken.next);
      if (afterName == null) {
        return false;
      }
      return _tokenMatches(afterName, TokenType.FUNCTION) ||
          _tokenMatches(afterName, TokenType.OPEN_CURLY_BRACKET);
    } else if (_tokenMatchesKeyword(afterReturnType, Keyword.GET)) {
      Token afterName = _skipSimpleIdentifier(afterReturnType.next);
      if (afterName == null) {
        return false;
      }
      return _tokenMatches(afterName, TokenType.FUNCTION) ||
          _tokenMatches(afterName, TokenType.OPEN_CURLY_BRACKET);
    }
    return false;
  }

  /**
   * Return `true` if the given [token] appears to be the beginning of a
   * function expression.
   */
  bool _isFunctionExpression(Token token) {
    // Function expressions aren't allowed in initializer lists.
    if (_inInitializer) {
      return false;
    }
    Token afterTypeParameters = _skipTypeParameterList(token);
    if (afterTypeParameters == null) {
      afterTypeParameters = token;
    }
    Token afterParameters = _skipFormalParameterList(afterTypeParameters);
    if (afterParameters == null) {
      return false;
    }
    if (afterParameters
        .matchesAny([TokenType.OPEN_CURLY_BRACKET, TokenType.FUNCTION])) {
      return true;
    }
    String lexeme = afterParameters.lexeme;
    return lexeme == ASYNC || lexeme == SYNC;
  }

  /**
   * Return `true` if the given [character] is a valid hexadecimal digit.
   */
  bool _isHexDigit(int character) => (0x30 <= character && character <= 0x39) ||
      (0x41 <= character && character <= 0x46) ||
      (0x61 <= character && character <= 0x66);

  /**
   * Return `true` if the current token is the first token in an initialized
   * variable declaration rather than an expression. This method assumes that we
   * have already skipped past any metadata that might be associated with the
   * declaration.
   *
   *     initializedVariableDeclaration ::=
   *         declaredIdentifier ('=' expression)? (',' initializedIdentifier)*
   *
   *     declaredIdentifier ::=
   *         metadata finalConstVarOrType identifier
   *
   *     finalConstVarOrType ::=
   *         'final' type?
   *       | 'const' type?
   *       | 'var'
   *       | type
   *
   *     type ::=
   *         qualified typeArguments?
   *
   *     initializedIdentifier ::=
   *         identifier ('=' expression)?
   */
  bool _isInitializedVariableDeclaration() {
    if (_matchesKeyword(Keyword.FINAL) || _matchesKeyword(Keyword.VAR)) {
      // An expression cannot start with a keyword other than 'const',
      // 'rethrow', or 'throw'.
      return true;
    }
    if (_matchesKeyword(Keyword.CONST)) {
      // Look to see whether we might be at the start of a list or map literal,
      // otherwise this should be the start of a variable declaration.
      return !_peek().matchesAny([
        TokenType.LT,
        TokenType.OPEN_CURLY_BRACKET,
        TokenType.OPEN_SQUARE_BRACKET,
        TokenType.INDEX
      ]);
    }
    // We know that we have an identifier, and need to see whether it might be
    // a type name.
    Token token = _skipTypeName(_currentToken);
    if (token == null) {
      // There was no type name, so this can't be a declaration.
      return false;
    }
    token = _skipSimpleIdentifier(token);
    if (token == null) {
      return false;
    }
    TokenType type = token.type;
    return type == TokenType.EQ ||
        type == TokenType.COMMA ||
        type == TokenType.SEMICOLON ||
        _tokenMatchesKeyword(token, Keyword.IN);
  }

  bool _isLikelyParameterList() {
    if (_matches(TokenType.OPEN_PAREN)) {
      return true;
    }
    if (!parseGenericMethods) {
      return false;
    }
    Token token = _skipTypeArgumentList(_currentToken);
    return token != null && _tokenMatches(token, TokenType.OPEN_PAREN);
  }

  /**
   * Given that we have just found bracketed text within the given [comment],
   * look to see whether that text is (a) followed by a parenthesized link
   * address, (b) followed by a colon, or (c) followed by optional whitespace
   * and another square bracket. The [rightIndex] is the index of the right
   * bracket. Return `true` if the bracketed text is followed by a link address.
   *
   * This method uses the syntax described by the
   * <a href="http://daringfireball.net/projects/markdown/syntax">markdown</a>
   * project.
   */
  bool _isLinkText(String comment, int rightIndex) {
    int length = comment.length;
    int index = rightIndex + 1;
    if (index >= length) {
      return false;
    }
    int nextChar = comment.codeUnitAt(index);
    if (nextChar == 0x28 || nextChar == 0x3A) {
      return true;
    }
    while (Character.isWhitespace(nextChar)) {
      index = index + 1;
      if (index >= length) {
        return false;
      }
      nextChar = comment.codeUnitAt(index);
    }
    return nextChar == 0x5B;
  }

  /**
   * Return `true` if the given [startToken] appears to be the beginning of an
   * operator declaration.
   */
  bool _isOperator(Token startToken) {
    // Accept any operator here, even if it is not user definable.
    if (!startToken.isOperator) {
      return false;
    }
    // Token "=" means that it is actually field initializer.
    if (startToken.type == TokenType.EQ) {
      return false;
    }
    // Consume all operator tokens.
    Token token = startToken.next;
    while (token.isOperator) {
      token = token.next;
    }
    // Formal parameter list is expect now.
    return _tokenMatches(token, TokenType.OPEN_PAREN);
  }

  /**
   * Return `true` if the current token appears to be the beginning of a switch
   * member.
   */
  bool _isSwitchMember() {
    Token token = _currentToken;
    while (_tokenMatches(token, TokenType.IDENTIFIER) &&
        _tokenMatches(token.next, TokenType.COLON)) {
      token = token.next.next;
    }
    if (token.type == TokenType.KEYWORD) {
      Keyword keyword = (token as KeywordToken).keyword;
      return keyword == Keyword.CASE || keyword == Keyword.DEFAULT;
    }
    return false;
  }

  /**
   * Return `true` if the [startToken] appears to be the first token of a type
   * name that is followed by a variable or field formal parameter.
   */
  bool _isTypedIdentifier(Token startToken) {
    Token token = _skipReturnType(startToken);
    if (token == null) {
      return false;
    } else if (_tokenMatchesIdentifier(token)) {
      return true;
    } else if (_tokenMatchesKeyword(token, Keyword.THIS) &&
        _tokenMatches(token.next, TokenType.PERIOD) &&
        _tokenMatchesIdentifier(token.next.next)) {
      return true;
    } else if (_tokenMatchesKeyword(startToken, Keyword.VOID)) {
      // The keyword 'void' isn't a valid identifier, so it should be assumed to
      // be a type name.
      return true;
    } else if (startToken.next != token &&
        !_tokenMatches(token, TokenType.OPEN_PAREN)) {
      // The type is more than a simple identifier, so it should be assumed to
      // be a type name.
      return true;
    }
    return false;
  }

  /**
   * Increments the error reporting lock level. If level is more than `0`, then
   * [reportError] wont report any error.
   */
  void _lockErrorListener() {
    _errorListenerLock++;
  }

  /**
   * Return `true` if the current token has the given [type]. Note that the
   * method [_matchesGt] should be used if the argument to this method would be
   * [TokenType.GT].
   */
  bool _matches(TokenType type) => _currentToken.type == type;

  /**
   * Return `true` if the current token has a type of [TokenType.GT]. Note that
   * this method, unlike other variants, will modify the token stream if
   * possible to match desired type. In particular, if the next token is either
   * a '>>' or '>>>', the token stream will be re-written and `true` will be
   * returned.
   */
  bool _matchesGt() {
    TokenType currentType = _currentToken.type;
    if (currentType == TokenType.GT) {
      return true;
    } else if (currentType == TokenType.GT_GT) {
      Token first = _createToken(_currentToken, TokenType.GT);
      Token second = new Token(TokenType.GT, _currentToken.offset + 1);
      second.setNext(_currentToken.next);
      first.setNext(second);
      _currentToken.previous.setNext(first);
      _currentToken = first;
      return true;
    } else if (currentType == TokenType.GT_EQ) {
      Token first = _createToken(_currentToken, TokenType.GT);
      Token second = new Token(TokenType.EQ, _currentToken.offset + 1);
      second.setNext(_currentToken.next);
      first.setNext(second);
      _currentToken.previous.setNext(first);
      _currentToken = first;
      return true;
    } else if (currentType == TokenType.GT_GT_EQ) {
      int offset = _currentToken.offset;
      Token first = _createToken(_currentToken, TokenType.GT);
      Token second = new Token(TokenType.GT, offset + 1);
      Token third = new Token(TokenType.EQ, offset + 2);
      third.setNext(_currentToken.next);
      second.setNext(third);
      first.setNext(second);
      _currentToken.previous.setNext(first);
      _currentToken = first;
      return true;
    }
    return false;
  }

  /**
   * Return `true` if the current token is a valid identifier. Valid identifiers
   * include built-in identifiers (pseudo-keywords).
   */
  bool _matchesIdentifier() => _tokenMatchesIdentifier(_currentToken);

  /**
   * Return `true` if the current token matches the given [keyword].
   */
  bool _matchesKeyword(Keyword keyword) =>
      _tokenMatchesKeyword(_currentToken, keyword);

  /**
   * Return `true` if the current token matches the given [identifier].
   */
  bool _matchesString(String identifier) =>
      _currentToken.type == TokenType.IDENTIFIER &&
          _currentToken.lexeme == identifier;

  /**
   * If the current token has the given [type], then advance to the next token
   * and return `true`. Otherwise, return `false` without advancing. This method
   * should not be invoked with an argument value of [TokenType.GT].
   */
  bool _optional(TokenType type) {
    if (_matches(type)) {
      _advance();
      return true;
    }
    return false;
  }

  /**
   * Parse an additive expression. Return the additive expression that was
   * parsed.
   *
   *     additiveExpression ::=
   *         multiplicativeExpression (additiveOperator multiplicativeExpression)*
   *       | 'super' (additiveOperator multiplicativeExpression)+
   */
  Expression _parseAdditiveExpression() {
    Expression expression;
    if (_matchesKeyword(Keyword.SUPER) &&
        _currentToken.next.type.isAdditiveOperator) {
      expression = new SuperExpression(getAndAdvance());
    } else {
      expression = _parseMultiplicativeExpression();
    }
    while (_currentToken.type.isAdditiveOperator) {
      Token operator = getAndAdvance();
      expression = new BinaryExpression(
          expression, operator, _parseMultiplicativeExpression());
    }
    return expression;
  }

  /**
   * Parse an assert statement. Return the assert statement.
   *
   *     assertStatement ::=
   *         'assert' '(' conditionalExpression ')' ';'
   */
  AssertStatement _parseAssertStatement() {
    Token keyword = _expectKeyword(Keyword.ASSERT);
    Token leftParen = _expect(TokenType.OPEN_PAREN);
    Expression expression = parseExpression2();
    if (expression is AssignmentExpression) {
      _reportErrorForNode(
          ParserErrorCode.ASSERT_DOES_NOT_TAKE_ASSIGNMENT, expression);
    } else if (expression is CascadeExpression) {
      _reportErrorForNode(
          ParserErrorCode.ASSERT_DOES_NOT_TAKE_CASCADE, expression);
    } else if (expression is ThrowExpression) {
      _reportErrorForNode(
          ParserErrorCode.ASSERT_DOES_NOT_TAKE_THROW, expression);
    } else if (expression is RethrowExpression) {
      _reportErrorForNode(
          ParserErrorCode.ASSERT_DOES_NOT_TAKE_RETHROW, expression);
    }
    Token rightParen = _expect(TokenType.CLOSE_PAREN);
    Token semicolon = _expect(TokenType.SEMICOLON);
    return new AssertStatement(
        keyword, leftParen, expression, rightParen, semicolon);
  }

  /**
   * Parse an assignable expression. The [primaryAllowed] is `true` if the
   * expression is allowed to be a primary without any assignable selector.
   * Return the assignable expression that was parsed.
   *
   *     assignableExpression ::=
   *         primary (arguments* assignableSelector)+
   *       | 'super' unconditionalAssignableSelector
   *       | identifier
   */
  Expression _parseAssignableExpression(bool primaryAllowed) {
    if (_matchesKeyword(Keyword.SUPER)) {
      return _parseAssignableSelector(
          new SuperExpression(getAndAdvance()), false, allowConditional: false);
    }
    //
    // A primary expression can start with an identifier. We resolve the
    // ambiguity by determining whether the primary consists of anything other
    // than an identifier and/or is followed by an assignableSelector.
    //
    Expression expression = _parsePrimaryExpression();
    bool isOptional = primaryAllowed || expression is SimpleIdentifier;
    while (true) {
      while (_isLikelyParameterList()) {
        TypeArgumentList typeArguments = null;
        if (_matches(TokenType.LT)) {
          typeArguments = parseTypeArgumentList();
        }
        ArgumentList argumentList = parseArgumentList();
        if (expression is SimpleIdentifier) {
          expression = new MethodInvocation(null, null,
              expression as SimpleIdentifier, typeArguments, argumentList);
        } else if (expression is PrefixedIdentifier) {
          PrefixedIdentifier identifier = expression as PrefixedIdentifier;
          expression = new MethodInvocation(identifier.prefix,
              identifier.period, identifier.identifier, typeArguments,
              argumentList);
        } else if (expression is PropertyAccess) {
          PropertyAccess access = expression as PropertyAccess;
          expression = new MethodInvocation(access.target, access.operator,
              access.propertyName, typeArguments, argumentList);
        } else {
          expression = new FunctionExpressionInvocation(
              expression, typeArguments, argumentList);
        }
        if (!primaryAllowed) {
          isOptional = false;
        }
      }
      Expression selectorExpression = _parseAssignableSelector(
          expression, isOptional || (expression is PrefixedIdentifier));
      if (identical(selectorExpression, expression)) {
        if (!isOptional && (expression is PrefixedIdentifier)) {
          PrefixedIdentifier identifier = expression as PrefixedIdentifier;
          expression = new PropertyAccess(
              identifier.prefix, identifier.period, identifier.identifier);
        }
        return expression;
      }
      expression = selectorExpression;
      isOptional = true;
    }
  }

  /**
   * Parse an assignable selector. The [prefix] is the expression preceding the
   * selector. The [optional] is `true` if the selector is optional. Return the
   * assignable selector that was parsed, or the original prefix if there was no
   * assignable selector.  If [allowConditional] is false, then the '?.'
   * operator will still be parsed, but a parse error will be generated.
   *
   *     unconditionalAssignableSelector ::=
   *         '[' expression ']'
   *       | '.' identifier
   *
   *     assignableSelector ::=
   *         unconditionalAssignableSelector
   *       | '?.' identifier
   */
  Expression _parseAssignableSelector(Expression prefix, bool optional,
      {bool allowConditional: true}) {
    if (_matches(TokenType.OPEN_SQUARE_BRACKET)) {
      Token leftBracket = getAndAdvance();
      bool wasInInitializer = _inInitializer;
      _inInitializer = false;
      try {
        Expression index = parseExpression2();
        Token rightBracket = _expect(TokenType.CLOSE_SQUARE_BRACKET);
        return new IndexExpression.forTarget(
            prefix, leftBracket, index, rightBracket);
      } finally {
        _inInitializer = wasInInitializer;
      }
    } else if (_matches(TokenType.PERIOD) ||
        _matches(TokenType.QUESTION_PERIOD)) {
      if (_matches(TokenType.QUESTION_PERIOD) && !allowConditional) {
        _reportErrorForCurrentToken(
            ParserErrorCode.INVALID_OPERATOR_FOR_SUPER, [_currentToken.lexeme]);
      }
      Token operator = getAndAdvance();
      return new PropertyAccess(prefix, operator, parseSimpleIdentifier());
    } else {
      if (!optional) {
        // Report the missing selector.
        _reportErrorForCurrentToken(
            ParserErrorCode.MISSING_ASSIGNABLE_SELECTOR);
      }
      return prefix;
    }
  }

  /**
   * Parse a await expression. Return the await expression that was parsed.
   *
   *     awaitExpression ::=
   *         'await' unaryExpression
   */
  AwaitExpression _parseAwaitExpression() {
    Token awaitToken = getAndAdvance();
    Expression expression = _parseUnaryExpression();
    return new AwaitExpression(awaitToken, expression);
  }

  /**
   * Parse a bitwise and expression. Return the bitwise and expression that was
   * parsed.
   *
   *     bitwiseAndExpression ::=
   *         shiftExpression ('&' shiftExpression)*
   *       | 'super' ('&' shiftExpression)+
   */
  Expression _parseBitwiseAndExpression() {
    Expression expression;
    if (_matchesKeyword(Keyword.SUPER) &&
        _tokenMatches(_peek(), TokenType.AMPERSAND)) {
      expression = new SuperExpression(getAndAdvance());
    } else {
      expression = _parseShiftExpression();
    }
    while (_matches(TokenType.AMPERSAND)) {
      Token operator = getAndAdvance();
      expression =
          new BinaryExpression(expression, operator, _parseShiftExpression());
    }
    return expression;
  }

  /**
   * Parse a bitwise exclusive-or expression. Return the bitwise exclusive-or
   * expression that was parsed.
   *
   *     bitwiseXorExpression ::=
   *         bitwiseAndExpression ('^' bitwiseAndExpression)*
   *       | 'super' ('^' bitwiseAndExpression)+
   */
  Expression _parseBitwiseXorExpression() {
    Expression expression;
    if (_matchesKeyword(Keyword.SUPER) &&
        _tokenMatches(_peek(), TokenType.CARET)) {
      expression = new SuperExpression(getAndAdvance());
    } else {
      expression = _parseBitwiseAndExpression();
    }
    while (_matches(TokenType.CARET)) {
      Token operator = getAndAdvance();
      expression = new BinaryExpression(
          expression, operator, _parseBitwiseAndExpression());
    }
    return expression;
  }

  /**
   * Parse a break statement. Return the break statement that was parsed.
   *
   *     breakStatement ::=
   *         'break' identifier? ';'
   */
  Statement _parseBreakStatement() {
    Token breakKeyword = _expectKeyword(Keyword.BREAK);
    SimpleIdentifier label = null;
    if (_matchesIdentifier()) {
      label = parseSimpleIdentifier();
    }
    if (!_inLoop && !_inSwitch && label == null) {
      _reportErrorForToken(ParserErrorCode.BREAK_OUTSIDE_OF_LOOP, breakKeyword);
    }
    Token semicolon = _expect(TokenType.SEMICOLON);
    return new BreakStatement(breakKeyword, label, semicolon);
  }

  /**
   * Parse a cascade section. Return the expression representing the cascaded
   * method invocation.
   *
   *     cascadeSection ::=
   *         '..' (cascadeSelector typeArguments? arguments*)
   *         (assignableSelector typeArguments? arguments*)* cascadeAssignment?
   *
   *     cascadeSelector ::=
   *         '[' expression ']'
   *       | identifier
   *
   *     cascadeAssignment ::=
   *         assignmentOperator expressionWithoutCascade
   */
  Expression _parseCascadeSection() {
    Token period = _expect(TokenType.PERIOD_PERIOD);
    Expression expression = null;
    SimpleIdentifier functionName = null;
    if (_matchesIdentifier()) {
      functionName = parseSimpleIdentifier();
    } else if (_currentToken.type == TokenType.OPEN_SQUARE_BRACKET) {
      Token leftBracket = getAndAdvance();
      bool wasInInitializer = _inInitializer;
      _inInitializer = false;
      try {
        Expression index = parseExpression2();
        Token rightBracket = _expect(TokenType.CLOSE_SQUARE_BRACKET);
        expression = new IndexExpression.forCascade(
            period, leftBracket, index, rightBracket);
        period = null;
      } finally {
        _inInitializer = wasInInitializer;
      }
    } else {
      _reportErrorForToken(ParserErrorCode.MISSING_IDENTIFIER, _currentToken,
          [_currentToken.lexeme]);
      functionName = _createSyntheticIdentifier();
    }
    assert((expression == null && functionName != null) ||
        (expression != null && functionName == null));
    if (_isLikelyParameterList()) {
      while (_isLikelyParameterList()) {
        TypeArgumentList typeArguments = null;
        if (_matches(TokenType.LT)) {
          typeArguments = parseTypeArgumentList();
        }
        if (functionName != null) {
          expression = new MethodInvocation(expression, period, functionName,
              typeArguments, parseArgumentList());
          period = null;
          functionName = null;
        } else if (expression == null) {
          // It should not be possible to get here.
          expression = new MethodInvocation(expression, period,
              _createSyntheticIdentifier(), typeArguments, parseArgumentList());
        } else {
          expression = new FunctionExpressionInvocation(
              expression, typeArguments, parseArgumentList());
        }
      }
    } else if (functionName != null) {
      expression = new PropertyAccess(expression, period, functionName);
      period = null;
    }
    assert(expression != null);
    bool progress = true;
    while (progress) {
      progress = false;
      Expression selector = _parseAssignableSelector(expression, true);
      if (!identical(selector, expression)) {
        expression = selector;
        progress = true;
        while (_isLikelyParameterList()) {
          TypeArgumentList typeArguments = null;
          if (_matches(TokenType.LT)) {
            typeArguments = parseTypeArgumentList();
          }
          if (expression is PropertyAccess) {
            PropertyAccess propertyAccess = expression as PropertyAccess;
            expression = new MethodInvocation(propertyAccess.target,
                propertyAccess.operator, propertyAccess.propertyName,
                typeArguments, parseArgumentList());
          } else {
            expression = new FunctionExpressionInvocation(
                expression, typeArguments, parseArgumentList());
          }
        }
      }
    }
    if (_currentToken.type.isAssignmentOperator) {
      Token operator = getAndAdvance();
      _ensureAssignable(expression);
      expression = new AssignmentExpression(
          expression, operator, parseExpressionWithoutCascade());
    }
    return expression;
  }

  /**
   * Parse a class declaration. The [commentAndMetadata] is the metadata to be
   * associated with the member. The [abstractKeyword] is the token for the
   * keyword 'abstract', or `null` if the keyword was not given. Return the
   * class declaration that was parsed.
   *
   *     classDeclaration ::=
   *         metadata 'abstract'? 'class' name typeParameterList? (extendsClause withClause?)? implementsClause? '{' classMembers '}' |
   *         metadata 'abstract'? 'class' mixinApplicationClass
   */
  CompilationUnitMember _parseClassDeclaration(
      CommentAndMetadata commentAndMetadata, Token abstractKeyword) {
    Token keyword = _expectKeyword(Keyword.CLASS);
    if (_matchesIdentifier()) {
      Token next = _peek();
      if (_tokenMatches(next, TokenType.LT)) {
        next = _skipTypeParameterList(next);
        if (next != null && _tokenMatches(next, TokenType.EQ)) {
          return _parseClassTypeAlias(
              commentAndMetadata, abstractKeyword, keyword);
        }
      } else if (_tokenMatches(next, TokenType.EQ)) {
        return _parseClassTypeAlias(
            commentAndMetadata, abstractKeyword, keyword);
      }
    }
    SimpleIdentifier name = parseSimpleIdentifier();
    String className = name.name;
    TypeParameterList typeParameters = null;
    if (_matches(TokenType.LT)) {
      typeParameters = parseTypeParameterList();
    }
    //
    // Parse the clauses. The parser accepts clauses in any order, but will
    // generate errors if they are not in the order required by the
    // specification.
    //
    ExtendsClause extendsClause = null;
    WithClause withClause = null;
    ImplementsClause implementsClause = null;
    bool foundClause = true;
    while (foundClause) {
      if (_matchesKeyword(Keyword.EXTENDS)) {
        if (extendsClause == null) {
          extendsClause = parseExtendsClause();
          if (withClause != null) {
            _reportErrorForToken(
                ParserErrorCode.WITH_BEFORE_EXTENDS, withClause.withKeyword);
          } else if (implementsClause != null) {
            _reportErrorForToken(ParserErrorCode.IMPLEMENTS_BEFORE_EXTENDS,
                implementsClause.implementsKeyword);
          }
        } else {
          _reportErrorForToken(ParserErrorCode.MULTIPLE_EXTENDS_CLAUSES,
              extendsClause.extendsKeyword);
          parseExtendsClause();
        }
      } else if (_matchesKeyword(Keyword.WITH)) {
        if (withClause == null) {
          withClause = parseWithClause();
          if (implementsClause != null) {
            _reportErrorForToken(ParserErrorCode.IMPLEMENTS_BEFORE_WITH,
                implementsClause.implementsKeyword);
          }
        } else {
          _reportErrorForToken(
              ParserErrorCode.MULTIPLE_WITH_CLAUSES, withClause.withKeyword);
          parseWithClause();
          // TODO(brianwilkerson) Should we merge the list of applied mixins
          // into a single list?
        }
      } else if (_matchesKeyword(Keyword.IMPLEMENTS)) {
        if (implementsClause == null) {
          implementsClause = parseImplementsClause();
        } else {
          _reportErrorForToken(ParserErrorCode.MULTIPLE_IMPLEMENTS_CLAUSES,
              implementsClause.implementsKeyword);
          parseImplementsClause();
          // TODO(brianwilkerson) Should we merge the list of implemented
          // classes into a single list?
        }
      } else {
        foundClause = false;
      }
    }
    if (withClause != null && extendsClause == null) {
      _reportErrorForToken(
          ParserErrorCode.WITH_WITHOUT_EXTENDS, withClause.withKeyword);
    }
    //
    // Look for and skip over the extra-lingual 'native' specification.
    //
    NativeClause nativeClause = null;
    if (_matchesString(_NATIVE) && _tokenMatches(_peek(), TokenType.STRING)) {
      nativeClause = _parseNativeClause();
    }
    //
    // Parse the body of the class.
    //
    Token leftBracket = null;
    List<ClassMember> members = null;
    Token rightBracket = null;
    if (_matches(TokenType.OPEN_CURLY_BRACKET)) {
      leftBracket = _expect(TokenType.OPEN_CURLY_BRACKET);
      members = _parseClassMembers(className, _getEndToken(leftBracket));
      rightBracket = _expect(TokenType.CLOSE_CURLY_BRACKET);
    } else {
      leftBracket = _createSyntheticToken(TokenType.OPEN_CURLY_BRACKET);
      rightBracket = _createSyntheticToken(TokenType.CLOSE_CURLY_BRACKET);
      _reportErrorForCurrentToken(ParserErrorCode.MISSING_CLASS_BODY);
    }
    ClassDeclaration classDeclaration = new ClassDeclaration(
        commentAndMetadata.comment, commentAndMetadata.metadata,
        abstractKeyword, keyword, name, typeParameters, extendsClause,
        withClause, implementsClause, leftBracket, members, rightBracket);
    classDeclaration.nativeClause = nativeClause;
    return classDeclaration;
  }

  /**
   * Parse a list of class members. The [className] is the name of the class
   * whose members are being parsed. The [closingBracket] is the closing bracket
   * for the class, or `null` if the closing bracket is missing. Return the list
   * of class members that were parsed.
   *
   *     classMembers ::=
   *         (metadata memberDefinition)*
   */
  List<ClassMember> _parseClassMembers(String className, Token closingBracket) {
    List<ClassMember> members = new List<ClassMember>();
    Token memberStart = _currentToken;
    while (!_matches(TokenType.EOF) &&
        !_matches(TokenType.CLOSE_CURLY_BRACKET) &&
        (closingBracket != null ||
            (!_matchesKeyword(Keyword.CLASS) &&
                !_matchesKeyword(Keyword.TYPEDEF)))) {
      if (_matches(TokenType.SEMICOLON)) {
        _reportErrorForToken(ParserErrorCode.UNEXPECTED_TOKEN, _currentToken,
            [_currentToken.lexeme]);
        _advance();
      } else {
        ClassMember member = parseClassMember(className);
        if (member != null) {
          members.add(member);
        }
      }
      if (identical(_currentToken, memberStart)) {
        _reportErrorForToken(ParserErrorCode.UNEXPECTED_TOKEN, _currentToken,
            [_currentToken.lexeme]);
        _advance();
      }
      memberStart = _currentToken;
    }
    return members;
  }

  /**
   * Parse a class type alias. The [commentAndMetadata] is the metadata to be
   * associated with the member. The [abstractKeyword] is the token representing
   * the 'abstract' keyword. The [classKeyword] is the token representing the
   * 'class' keyword. Return the class type alias that was parsed.
   *
   *     classTypeAlias ::=
   *         identifier typeParameters? '=' 'abstract'? mixinApplication
   *
   *     mixinApplication ::=
   *         type withClause implementsClause? ';'
   */
  ClassTypeAlias _parseClassTypeAlias(CommentAndMetadata commentAndMetadata,
      Token abstractKeyword, Token classKeyword) {
    SimpleIdentifier className = parseSimpleIdentifier();
    TypeParameterList typeParameters = null;
    if (_matches(TokenType.LT)) {
      typeParameters = parseTypeParameterList();
    }
    Token equals = _expect(TokenType.EQ);
    TypeName superclass = parseTypeName();
    WithClause withClause = null;
    if (_matchesKeyword(Keyword.WITH)) {
      withClause = parseWithClause();
    } else {
      _reportErrorForCurrentToken(
          ParserErrorCode.EXPECTED_TOKEN, [Keyword.WITH.syntax]);
    }
    ImplementsClause implementsClause = null;
    if (_matchesKeyword(Keyword.IMPLEMENTS)) {
      implementsClause = parseImplementsClause();
    }
    Token semicolon;
    if (_matches(TokenType.SEMICOLON)) {
      semicolon = getAndAdvance();
    } else {
      if (_matches(TokenType.OPEN_CURLY_BRACKET)) {
        _reportErrorForCurrentToken(
            ParserErrorCode.EXPECTED_TOKEN, [TokenType.SEMICOLON.lexeme]);
        Token leftBracket = getAndAdvance();
        _parseClassMembers(className.name, _getEndToken(leftBracket));
        _expect(TokenType.CLOSE_CURLY_BRACKET);
      } else {
        _reportErrorForToken(ParserErrorCode.EXPECTED_TOKEN,
            _currentToken.previous, [TokenType.SEMICOLON.lexeme]);
      }
      semicolon = _createSyntheticToken(TokenType.SEMICOLON);
    }
    return new ClassTypeAlias(commentAndMetadata.comment,
        commentAndMetadata.metadata, classKeyword, className, typeParameters,
        equals, abstractKeyword, superclass, withClause, implementsClause,
        semicolon);
  }

  /**
   * Parse a list of combinators in a directive. Return the combinators that
   * were parsed.
   *
   *     combinator ::=
   *         'show' identifier (',' identifier)*
   *       | 'hide' identifier (',' identifier)*
   */
  List<Combinator> _parseCombinators() {
    List<Combinator> combinators = new List<Combinator>();
    while (true) {
      Combinator combinator = parseCombinator();
      if (combinator == null) {
        break;
      }
      combinators.add(combinator);
    }
    return combinators;
  }

  /**
   * Parse the documentation comment and metadata preceding a declaration. This
   * method allows any number of documentation comments to occur before, after
   * or between the metadata, but only returns the last (right-most)
   * documentation comment that is found. Return the documentation comment and
   * metadata that were parsed.
   *
   *     metadata ::=
   *         annotation*
   */
  CommentAndMetadata _parseCommentAndMetadata() {
    Comment comment = _parseDocumentationComment();
    List<Annotation> metadata = new List<Annotation>();
    while (_matches(TokenType.AT)) {
      metadata.add(parseAnnotation());
      Comment optionalComment = _parseDocumentationComment();
      if (optionalComment != null) {
        comment = optionalComment;
      }
    }
    return new CommentAndMetadata(comment, metadata);
  }

  /**
   * Parse a comment reference from the source between square brackets. The
   * [referenceSource] is the source occurring between the square brackets
   * within a documentation comment. The [sourceOffset] is the offset of the
   * first character of the reference source. Return the comment reference that
   * was parsed, or `null` if no reference could be found.
   *
   *     commentReference ::=
   *         'new'? prefixedIdentifier
   */
  CommentReference _parseCommentReference(
      String referenceSource, int sourceOffset) {
    // TODO(brianwilkerson) The errors are not getting the right offset/length
    // and are being duplicated.
    if (referenceSource.length == 0) {
      Token syntheticToken =
          new SyntheticStringToken(TokenType.IDENTIFIER, "", sourceOffset);
      return new CommentReference(null, new SimpleIdentifier(syntheticToken));
    }
    try {
      BooleanErrorListener listener = new BooleanErrorListener();
      Scanner scanner = new Scanner(
          null, new SubSequenceReader(referenceSource, sourceOffset), listener);
      scanner.setSourceStart(1, 1);
      Token firstToken = scanner.tokenize();
      if (listener.errorReported) {
        return null;
      }
      Token newKeyword = null;
      if (_tokenMatchesKeyword(firstToken, Keyword.NEW)) {
        newKeyword = firstToken;
        firstToken = firstToken.next;
      }
      if (_tokenMatchesIdentifier(firstToken)) {
        Token secondToken = firstToken.next;
        Token thirdToken = secondToken.next;
        Token nextToken;
        Identifier identifier;
        if (_tokenMatches(secondToken, TokenType.PERIOD) &&
            _tokenMatchesIdentifier(thirdToken)) {
          identifier = new PrefixedIdentifier(new SimpleIdentifier(firstToken),
              secondToken, new SimpleIdentifier(thirdToken));
          nextToken = thirdToken.next;
        } else {
          identifier = new SimpleIdentifier(firstToken);
          nextToken = firstToken.next;
        }
        if (nextToken.type != TokenType.EOF) {
          return null;
        }
        return new CommentReference(newKeyword, identifier);
      } else if (_tokenMatchesKeyword(firstToken, Keyword.THIS) ||
          _tokenMatchesKeyword(firstToken, Keyword.NULL) ||
          _tokenMatchesKeyword(firstToken, Keyword.TRUE) ||
          _tokenMatchesKeyword(firstToken, Keyword.FALSE)) {
        // TODO(brianwilkerson) If we want to support this we will need to
        // extend the definition of CommentReference to take an expression
        // rather than an identifier. For now we just ignore it to reduce the
        // number of errors produced, but that's probably not a valid long term
        // approach.
        return null;
      }
    } catch (exception) {
      // Ignored because we assume that it wasn't a real comment reference.
    }
    return null;
  }

  /**
   * Parse all of the comment references occurring in the given array of
   * documentation comments. The [tokens] are the comment tokens representing
   * the documentation comments to be parsed. Return the comment references that
   * were parsed.
   *
   *     commentReference ::=
   *         '[' 'new'? qualified ']' libraryReference?
   *
   *     libraryReference ::=
   *          '(' stringLiteral ')'
   */
  List<CommentReference> _parseCommentReferences(
      List<DocumentationCommentToken> tokens) {
    List<CommentReference> references = new List<CommentReference>();
    for (DocumentationCommentToken token in tokens) {
      String comment = token.lexeme;
      int length = comment.length;
      List<List<int>> codeBlockRanges = _getCodeBlockRanges(comment);
      int leftIndex = comment.indexOf('[');
      while (leftIndex >= 0 && leftIndex + 1 < length) {
        List<int> range = _findRange(codeBlockRanges, leftIndex);
        if (range == null) {
          int nameOffset = token.offset + leftIndex + 1;
          int rightIndex = JavaString.indexOf(comment, ']', leftIndex);
          if (rightIndex >= 0) {
            int firstChar = comment.codeUnitAt(leftIndex + 1);
            if (firstChar != 0x27 && firstChar != 0x22) {
              if (_isLinkText(comment, rightIndex)) {
                // TODO(brianwilkerson) Handle the case where there's a library
                // URI in the link text.
              } else {
                CommentReference reference = _parseCommentReference(
                    comment.substring(leftIndex + 1, rightIndex), nameOffset);
                if (reference != null) {
                  references.add(reference);
                  token.references.add(reference.beginToken);
                }
              }
            }
          } else {
            // terminating ']' is not typed yet
            int charAfterLeft = comment.codeUnitAt(leftIndex + 1);
            if (Character.isLetterOrDigit(charAfterLeft)) {
              int nameEnd = StringUtilities.indexOfFirstNotLetterDigit(
                  comment, leftIndex + 1);
              String name = comment.substring(leftIndex + 1, nameEnd);
              Token nameToken =
                  new StringToken(TokenType.IDENTIFIER, name, nameOffset);
              references.add(
                  new CommentReference(null, new SimpleIdentifier(nameToken)));
            } else {
              Token nameToken = new SyntheticStringToken(
                  TokenType.IDENTIFIER, "", nameOffset);
              references.add(
                  new CommentReference(null, new SimpleIdentifier(nameToken)));
            }
            // next character
            rightIndex = leftIndex + 1;
          }
          leftIndex = JavaString.indexOf(comment, '[', rightIndex);
        } else {
          leftIndex = JavaString.indexOf(comment, '[', range[1] + 1);
        }
      }
    }
    return references;
  }

  /**
   * Parse a compilation unit member. The [commentAndMetadata] is the metadata
   * to be associated with the member. Return the compilation unit member that
   * was parsed, or `null` if what was parsed could not be represented as a
   * compilation unit member.
   *
   *     compilationUnitMember ::=
   *         classDefinition
   *       | functionTypeAlias
   *       | external functionSignature
   *       | external getterSignature
   *       | external setterSignature
   *       | functionSignature functionBody
   *       | returnType? getOrSet identifier formalParameterList functionBody
   *       | (final | const) type? staticFinalDeclarationList ';'
   *       | variableDeclaration ';'
   */
  CompilationUnitMember _parseCompilationUnitMember(
      CommentAndMetadata commentAndMetadata) {
    Modifiers modifiers = _parseModifiers();
    if (_matchesKeyword(Keyword.CLASS)) {
      return _parseClassDeclaration(
          commentAndMetadata, _validateModifiersForClass(modifiers));
    } else if (_matchesKeyword(Keyword.TYPEDEF) &&
        !_tokenMatches(_peek(), TokenType.PERIOD) &&
        !_tokenMatches(_peek(), TokenType.LT) &&
        !_tokenMatches(_peek(), TokenType.OPEN_PAREN)) {
      _validateModifiersForTypedef(modifiers);
      return _parseTypeAlias(commentAndMetadata);
    } else if (_matchesKeyword(Keyword.ENUM)) {
      _validateModifiersForEnum(modifiers);
      return _parseEnumDeclaration(commentAndMetadata);
    }
    if (_matchesKeyword(Keyword.VOID)) {
      TypeName returnType = parseReturnType();
      if ((_matchesKeyword(Keyword.GET) || _matchesKeyword(Keyword.SET)) &&
          _tokenMatchesIdentifier(_peek())) {
        _validateModifiersForTopLevelFunction(modifiers);
        return _parseFunctionDeclaration(
            commentAndMetadata, modifiers.externalKeyword, returnType);
      } else if (_matchesKeyword(Keyword.OPERATOR) && _isOperator(_peek())) {
        _reportErrorForToken(ParserErrorCode.TOP_LEVEL_OPERATOR, _currentToken);
        return _convertToFunctionDeclaration(_parseOperator(
            commentAndMetadata, modifiers.externalKeyword, returnType));
      } else if (_matchesIdentifier() &&
          _peek().matchesAny([
        TokenType.OPEN_PAREN,
        TokenType.OPEN_CURLY_BRACKET,
        TokenType.FUNCTION
      ])) {
        _validateModifiersForTopLevelFunction(modifiers);
        return _parseFunctionDeclaration(
            commentAndMetadata, modifiers.externalKeyword, returnType);
      } else {
        //
        // We have found an error of some kind. Try to recover.
        //
        if (_matchesIdentifier()) {
          if (_peek().matchesAny(
              [TokenType.EQ, TokenType.COMMA, TokenType.SEMICOLON])) {
            //
            // We appear to have a variable declaration with a type of "void".
            //
            _reportErrorForNode(ParserErrorCode.VOID_VARIABLE, returnType);
            return new TopLevelVariableDeclaration(commentAndMetadata.comment,
                commentAndMetadata.metadata,
                _parseVariableDeclarationListAfterType(null,
                    _validateModifiersForTopLevelVariable(modifiers), null),
                _expect(TokenType.SEMICOLON));
          }
        }
        _reportErrorForToken(
            ParserErrorCode.EXPECTED_EXECUTABLE, _currentToken);
        return null;
      }
    } else if ((_matchesKeyword(Keyword.GET) || _matchesKeyword(Keyword.SET)) &&
        _tokenMatchesIdentifier(_peek())) {
      _validateModifiersForTopLevelFunction(modifiers);
      return _parseFunctionDeclaration(
          commentAndMetadata, modifiers.externalKeyword, null);
    } else if (_matchesKeyword(Keyword.OPERATOR) && _isOperator(_peek())) {
      _reportErrorForToken(ParserErrorCode.TOP_LEVEL_OPERATOR, _currentToken);
      return _convertToFunctionDeclaration(
          _parseOperator(commentAndMetadata, modifiers.externalKeyword, null));
    } else if (!_matchesIdentifier()) {
      Token keyword = modifiers.varKeyword;
      if (keyword == null) {
        keyword = modifiers.finalKeyword;
      }
      if (keyword == null) {
        keyword = modifiers.constKeyword;
      }
      if (keyword != null) {
        //
        // We appear to have found an incomplete top-level variable declaration.
        //
        _reportErrorForCurrentToken(ParserErrorCode.MISSING_IDENTIFIER);
        List<VariableDeclaration> variables = new List<VariableDeclaration>();
        variables.add(
            new VariableDeclaration(_createSyntheticIdentifier(), null, null));
        return new TopLevelVariableDeclaration(commentAndMetadata.comment,
            commentAndMetadata.metadata,
            new VariableDeclarationList(null, null, keyword, null, variables),
            _expectSemicolon());
      }
      _reportErrorForToken(ParserErrorCode.EXPECTED_EXECUTABLE, _currentToken);
      return null;
    } else if (_tokenMatches(_peek(), TokenType.OPEN_PAREN)) {
      _validateModifiersForTopLevelFunction(modifiers);
      return _parseFunctionDeclaration(
          commentAndMetadata, modifiers.externalKeyword, null);
    } else if (_peek()
        .matchesAny([TokenType.EQ, TokenType.COMMA, TokenType.SEMICOLON])) {
      if (modifiers.constKeyword == null &&
          modifiers.finalKeyword == null &&
          modifiers.varKeyword == null) {
        _reportErrorForCurrentToken(
            ParserErrorCode.MISSING_CONST_FINAL_VAR_OR_TYPE);
      }
      return new TopLevelVariableDeclaration(commentAndMetadata.comment,
          commentAndMetadata.metadata, _parseVariableDeclarationListAfterType(
              null, _validateModifiersForTopLevelVariable(modifiers), null),
          _expect(TokenType.SEMICOLON));
    }
    TypeName returnType = parseReturnType();
    if ((_matchesKeyword(Keyword.GET) || _matchesKeyword(Keyword.SET)) &&
        _tokenMatchesIdentifier(_peek())) {
      _validateModifiersForTopLevelFunction(modifiers);
      return _parseFunctionDeclaration(
          commentAndMetadata, modifiers.externalKeyword, returnType);
    } else if (_matchesKeyword(Keyword.OPERATOR) && _isOperator(_peek())) {
      _reportErrorForToken(ParserErrorCode.TOP_LEVEL_OPERATOR, _currentToken);
      return _convertToFunctionDeclaration(_parseOperator(
          commentAndMetadata, modifiers.externalKeyword, returnType));
    } else if (_matches(TokenType.AT)) {
      return new TopLevelVariableDeclaration(commentAndMetadata.comment,
          commentAndMetadata.metadata, _parseVariableDeclarationListAfterType(
              null, _validateModifiersForTopLevelVariable(modifiers),
              returnType), _expect(TokenType.SEMICOLON));
    } else if (!_matchesIdentifier()) {
      // TODO(brianwilkerson) Generalize this error. We could also be parsing a
      // top-level variable at this point.
      _reportErrorForToken(ParserErrorCode.EXPECTED_EXECUTABLE, _currentToken);
      Token semicolon;
      if (_matches(TokenType.SEMICOLON)) {
        semicolon = getAndAdvance();
      } else {
        semicolon = _createSyntheticToken(TokenType.SEMICOLON);
      }
      List<VariableDeclaration> variables = new List<VariableDeclaration>();
      variables.add(
          new VariableDeclaration(_createSyntheticIdentifier(), null, null));
      return new TopLevelVariableDeclaration(commentAndMetadata.comment,
          commentAndMetadata.metadata,
          new VariableDeclarationList(null, null, null, returnType, variables),
          semicolon);
    }
    if (_peek().matchesAny([
      TokenType.OPEN_PAREN,
      TokenType.FUNCTION,
      TokenType.OPEN_CURLY_BRACKET
    ])) {
      _validateModifiersForTopLevelFunction(modifiers);
      return _parseFunctionDeclaration(
          commentAndMetadata, modifiers.externalKeyword, returnType);
    }
    return new TopLevelVariableDeclaration(commentAndMetadata.comment,
        commentAndMetadata.metadata, _parseVariableDeclarationListAfterType(
            null, _validateModifiersForTopLevelVariable(modifiers), returnType),
        _expect(TokenType.SEMICOLON));
  }

  /**
   * Parse a const expression. Return the const expression that was parsed.
   *
   *     constExpression ::=
   *         instanceCreationExpression
   *       | listLiteral
   *       | mapLiteral
   */
  Expression _parseConstExpression() {
    Token keyword = _expectKeyword(Keyword.CONST);
    if (_matches(TokenType.OPEN_SQUARE_BRACKET) || _matches(TokenType.INDEX)) {
      return _parseListLiteral(keyword, null);
    } else if (_matches(TokenType.OPEN_CURLY_BRACKET)) {
      return _parseMapLiteral(keyword, null);
    } else if (_matches(TokenType.LT)) {
      return _parseListOrMapLiteral(keyword);
    }
    return _parseInstanceCreationExpression(keyword);
  }

  ConstructorDeclaration _parseConstructor(
      CommentAndMetadata commentAndMetadata, Token externalKeyword,
      Token constKeyword, Token factoryKeyword, SimpleIdentifier returnType,
      Token period, SimpleIdentifier name, FormalParameterList parameters) {
    bool bodyAllowed = externalKeyword == null;
    Token separator = null;
    List<ConstructorInitializer> initializers = null;
    if (_matches(TokenType.COLON)) {
      separator = getAndAdvance();
      initializers = new List<ConstructorInitializer>();
      do {
        if (_matchesKeyword(Keyword.THIS)) {
          if (_tokenMatches(_peek(), TokenType.OPEN_PAREN)) {
            bodyAllowed = false;
            initializers.add(_parseRedirectingConstructorInvocation());
          } else if (_tokenMatches(_peek(), TokenType.PERIOD) &&
              _tokenMatches(_peekAt(3), TokenType.OPEN_PAREN)) {
            bodyAllowed = false;
            initializers.add(_parseRedirectingConstructorInvocation());
          } else {
            initializers.add(_parseConstructorFieldInitializer());
          }
        } else if (_matchesKeyword(Keyword.SUPER)) {
          initializers.add(_parseSuperConstructorInvocation());
        } else if (_matches(TokenType.OPEN_CURLY_BRACKET) ||
            _matches(TokenType.FUNCTION)) {
          _reportErrorForCurrentToken(ParserErrorCode.MISSING_INITIALIZER);
        } else {
          initializers.add(_parseConstructorFieldInitializer());
        }
      } while (_optional(TokenType.COMMA));
      if (factoryKeyword != null) {
        _reportErrorForToken(
            ParserErrorCode.FACTORY_WITH_INITIALIZERS, factoryKeyword);
      }
    }
    ConstructorName redirectedConstructor = null;
    FunctionBody body;
    if (_matches(TokenType.EQ)) {
      separator = getAndAdvance();
      redirectedConstructor = parseConstructorName();
      body = new EmptyFunctionBody(_expect(TokenType.SEMICOLON));
      if (factoryKeyword == null) {
        _reportErrorForNode(
            ParserErrorCode.REDIRECTION_IN_NON_FACTORY_CONSTRUCTOR,
            redirectedConstructor);
      }
    } else {
      body = _parseFunctionBody(
          true, ParserErrorCode.MISSING_FUNCTION_BODY, false);
      if (constKeyword != null &&
          factoryKeyword != null &&
          externalKeyword == null) {
        _reportErrorForToken(ParserErrorCode.CONST_FACTORY, factoryKeyword);
      } else if (body is EmptyFunctionBody) {
        if (factoryKeyword != null &&
            externalKeyword == null &&
            _parseFunctionBodies) {
          _reportErrorForToken(
              ParserErrorCode.FACTORY_WITHOUT_BODY, factoryKeyword);
        }
      } else {
        if (constKeyword != null) {
          _reportErrorForNode(
              ParserErrorCode.CONST_CONSTRUCTOR_WITH_BODY, body);
        } else if (!bodyAllowed) {
          _reportErrorForNode(
              ParserErrorCode.EXTERNAL_CONSTRUCTOR_WITH_BODY, body);
        }
      }
    }
    return new ConstructorDeclaration(commentAndMetadata.comment,
        commentAndMetadata.metadata, externalKeyword, constKeyword,
        factoryKeyword, returnType, period, name, parameters, separator,
        initializers, redirectedConstructor, body);
  }

  /**
   * Parse a field initializer within a constructor. Return the field
   * initializer that was parsed.
   *
   *     fieldInitializer:
   *         ('this' '.')? identifier '=' conditionalExpression cascadeSection*
   */
  ConstructorFieldInitializer _parseConstructorFieldInitializer() {
    Token keyword = null;
    Token period = null;
    if (_matchesKeyword(Keyword.THIS)) {
      keyword = getAndAdvance();
      period = _expect(TokenType.PERIOD);
    }
    SimpleIdentifier fieldName = parseSimpleIdentifier();
    Token equals = null;
    if (_matches(TokenType.EQ)) {
      equals = getAndAdvance();
    } else if (!_matchesKeyword(Keyword.THIS) &&
        !_matchesKeyword(Keyword.SUPER) &&
        !_matches(TokenType.OPEN_CURLY_BRACKET) &&
        !_matches(TokenType.FUNCTION)) {
      _reportErrorForCurrentToken(
          ParserErrorCode.MISSING_ASSIGNMENT_IN_INITIALIZER);
      equals = _createSyntheticToken(TokenType.EQ);
    } else {
      _reportErrorForCurrentToken(
          ParserErrorCode.MISSING_ASSIGNMENT_IN_INITIALIZER);
      return new ConstructorFieldInitializer(keyword, period, fieldName,
          _createSyntheticToken(TokenType.EQ), _createSyntheticIdentifier());
    }
    bool wasInInitializer = _inInitializer;
    _inInitializer = true;
    try {
      Expression expression = parseConditionalExpression();
      TokenType tokenType = _currentToken.type;
      if (tokenType == TokenType.PERIOD_PERIOD) {
        List<Expression> cascadeSections = new List<Expression>();
        while (tokenType == TokenType.PERIOD_PERIOD) {
          Expression section = _parseCascadeSection();
          if (section != null) {
            cascadeSections.add(section);
          }
          tokenType = _currentToken.type;
        }
        expression = new CascadeExpression(expression, cascadeSections);
      }
      return new ConstructorFieldInitializer(
          keyword, period, fieldName, equals, expression);
    } finally {
      _inInitializer = wasInInitializer;
    }
  }

  /**
   * Parse a continue statement. Return the continue statement that was parsed.
   *
   *     continueStatement ::=
   *         'continue' identifier? ';'
   */
  Statement _parseContinueStatement() {
    Token continueKeyword = _expectKeyword(Keyword.CONTINUE);
    if (!_inLoop && !_inSwitch) {
      _reportErrorForToken(
          ParserErrorCode.CONTINUE_OUTSIDE_OF_LOOP, continueKeyword);
    }
    SimpleIdentifier label = null;
    if (_matchesIdentifier()) {
      label = parseSimpleIdentifier();
    }
    if (_inSwitch && !_inLoop && label == null) {
      _reportErrorForToken(
          ParserErrorCode.CONTINUE_WITHOUT_LABEL_IN_CASE, continueKeyword);
    }
    Token semicolon = _expect(TokenType.SEMICOLON);
    return new ContinueStatement(continueKeyword, label, semicolon);
  }

  /**
   * Parse a directive. The [commentAndMetadata] is the metadata to be
   * associated with the directive. Return the directive that was parsed.
   *
   *     directive ::=
   *         exportDirective
   *       | libraryDirective
   *       | importDirective
   *       | partDirective
   */
  Directive _parseDirective(CommentAndMetadata commentAndMetadata) {
    if (_matchesKeyword(Keyword.IMPORT)) {
      return _parseImportDirective(commentAndMetadata);
    } else if (_matchesKeyword(Keyword.EXPORT)) {
      return _parseExportDirective(commentAndMetadata);
    } else if (_matchesKeyword(Keyword.LIBRARY)) {
      return _parseLibraryDirective(commentAndMetadata);
    } else if (_matchesKeyword(Keyword.PART)) {
      return _parsePartDirective(commentAndMetadata);
    } else {
      // Internal error: this method should not have been invoked if the current
      // token was something other than one of the above.
      throw new IllegalStateException(
          "parseDirective invoked in an invalid state; currentToken = $_currentToken");
    }
  }

  /**
   * Parse the script tag and directives in a compilation unit until the first
   * non-directive is encountered. Return the compilation unit that was parsed.
   *
   *     compilationUnit ::=
   *         scriptTag? directive*
   */
  CompilationUnit _parseDirectives() {
    Token firstToken = _currentToken;
    ScriptTag scriptTag = null;
    if (_matches(TokenType.SCRIPT_TAG)) {
      scriptTag = new ScriptTag(getAndAdvance());
    }
    List<Directive> directives = new List<Directive>();
    while (!_matches(TokenType.EOF)) {
      CommentAndMetadata commentAndMetadata = _parseCommentAndMetadata();
      if ((_matchesKeyword(Keyword.IMPORT) ||
              _matchesKeyword(Keyword.EXPORT) ||
              _matchesKeyword(Keyword.LIBRARY) ||
              _matchesKeyword(Keyword.PART)) &&
          !_tokenMatches(_peek(), TokenType.PERIOD) &&
          !_tokenMatches(_peek(), TokenType.LT) &&
          !_tokenMatches(_peek(), TokenType.OPEN_PAREN)) {
        directives.add(_parseDirective(commentAndMetadata));
      } else if (_matches(TokenType.SEMICOLON)) {
        _advance();
      } else {
        while (!_matches(TokenType.EOF)) {
          _advance();
        }
        return new CompilationUnit(firstToken, scriptTag, directives,
            new List<CompilationUnitMember>(), _currentToken);
      }
    }
    return new CompilationUnit(firstToken, scriptTag, directives,
        new List<CompilationUnitMember>(), _currentToken);
  }

  /**
   * Parse a documentation comment. Return the documentation comment that was
   * parsed, or `null` if there was no comment.
   *
   *     documentationComment ::=
   *         multiLineComment?
   *       | singleLineComment*
   */
  Comment _parseDocumentationComment() {
    List<DocumentationCommentToken> documentationTokens =
        <DocumentationCommentToken>[];
    CommentToken commentToken = _currentToken.precedingComments;
    while (commentToken != null) {
      if (commentToken is DocumentationCommentToken) {
        if (documentationTokens.isNotEmpty) {
          if (commentToken.type == TokenType.SINGLE_LINE_COMMENT) {
            if (documentationTokens[0].type != TokenType.SINGLE_LINE_COMMENT) {
              documentationTokens.clear();
            }
          } else {
            documentationTokens.clear();
          }
        }
        documentationTokens.add(commentToken);
      }
      commentToken = commentToken.next;
    }
    if (documentationTokens.isEmpty) {
      return null;
    }
    List<CommentReference> references =
        _parseCommentReferences(documentationTokens);
    return Comment.createDocumentationCommentWithReferences(
        documentationTokens, references);
  }

  /**
   * Parse a do statement. Return the do statement that was parsed.
   *
   *     doStatement ::=
   *         'do' statement 'while' '(' expression ')' ';'
   */
  Statement _parseDoStatement() {
    bool wasInLoop = _inLoop;
    _inLoop = true;
    try {
      Token doKeyword = _expectKeyword(Keyword.DO);
      Statement body = parseStatement2();
      Token whileKeyword = _expectKeyword(Keyword.WHILE);
      Token leftParenthesis = _expect(TokenType.OPEN_PAREN);
      Expression condition = parseExpression2();
      Token rightParenthesis = _expect(TokenType.CLOSE_PAREN);
      Token semicolon = _expect(TokenType.SEMICOLON);
      return new DoStatement(doKeyword, body, whileKeyword, leftParenthesis,
          condition, rightParenthesis, semicolon);
    } finally {
      _inLoop = wasInLoop;
    }
  }

  /**
   * Parse an empty statement. Return the empty statement that was parsed.
   *
   *     emptyStatement ::=
   *         ';'
   */
  Statement _parseEmptyStatement() => new EmptyStatement(getAndAdvance());

  EnumConstantDeclaration _parseEnumConstantDeclaration() {
    CommentAndMetadata commentAndMetadata = _parseCommentAndMetadata();
    SimpleIdentifier name;
    if (_matchesIdentifier()) {
      name = parseSimpleIdentifier();
    } else {
      name = _createSyntheticIdentifier();
    }
    if (commentAndMetadata.metadata.isNotEmpty) {
      _reportErrorForNode(ParserErrorCode.ANNOTATION_ON_ENUM_CONSTANT,
          commentAndMetadata.metadata[0]);
    }
    return new EnumConstantDeclaration(
        commentAndMetadata.comment, commentAndMetadata.metadata, name);
  }

  /**
   * Parse an enum declaration. The [commentAndMetadata] is the metadata to be
   * associated with the member. Return the enum declaration that was parsed.
   *
   *     enumType ::=
   *         metadata 'enum' id '{' id (',' id)* (',')? '}'
   */
  EnumDeclaration _parseEnumDeclaration(CommentAndMetadata commentAndMetadata) {
    Token keyword = _expectKeyword(Keyword.ENUM);
    SimpleIdentifier name = parseSimpleIdentifier();
    Token leftBracket = null;
    List<EnumConstantDeclaration> constants =
        new List<EnumConstantDeclaration>();
    Token rightBracket = null;
    if (_matches(TokenType.OPEN_CURLY_BRACKET)) {
      leftBracket = _expect(TokenType.OPEN_CURLY_BRACKET);
      if (_matchesIdentifier() || _matches(TokenType.AT)) {
        constants.add(_parseEnumConstantDeclaration());
      } else if (_matches(TokenType.COMMA) &&
          _tokenMatchesIdentifier(_peek())) {
        constants.add(_parseEnumConstantDeclaration());
        _reportErrorForCurrentToken(ParserErrorCode.MISSING_IDENTIFIER);
      } else {
        constants.add(_parseEnumConstantDeclaration());
        _reportErrorForCurrentToken(ParserErrorCode.EMPTY_ENUM_BODY);
      }
      while (_optional(TokenType.COMMA)) {
        if (_matches(TokenType.CLOSE_CURLY_BRACKET)) {
          break;
        }
        constants.add(_parseEnumConstantDeclaration());
      }
      rightBracket = _expect(TokenType.CLOSE_CURLY_BRACKET);
    } else {
      leftBracket = _createSyntheticToken(TokenType.OPEN_CURLY_BRACKET);
      rightBracket = _createSyntheticToken(TokenType.CLOSE_CURLY_BRACKET);
      _reportErrorForCurrentToken(ParserErrorCode.MISSING_ENUM_BODY);
    }
    return new EnumDeclaration(commentAndMetadata.comment,
        commentAndMetadata.metadata, keyword, name, leftBracket, constants,
        rightBracket);
  }

  /**
   * Parse an equality expression. Return the equality expression that was
   * parsed.
   *
   *     equalityExpression ::=
   *         relationalExpression (equalityOperator relationalExpression)?
   *       | 'super' equalityOperator relationalExpression
   */
  Expression _parseEqualityExpression() {
    Expression expression;
    if (_matchesKeyword(Keyword.SUPER) &&
        _currentToken.next.type.isEqualityOperator) {
      expression = new SuperExpression(getAndAdvance());
    } else {
      expression = _parseRelationalExpression();
    }
    bool leftEqualityExpression = false;
    while (_currentToken.type.isEqualityOperator) {
      Token operator = getAndAdvance();
      if (leftEqualityExpression) {
        _reportErrorForNode(
            ParserErrorCode.EQUALITY_CANNOT_BE_EQUALITY_OPERAND, expression);
      }
      expression = new BinaryExpression(
          expression, operator, _parseRelationalExpression());
      leftEqualityExpression = true;
    }
    return expression;
  }

  /**
   * Parse an export directive. The [commentAndMetadata] is the metadata to be
   * associated with the directive. Return the export directive that was parsed.
   *
   *     exportDirective ::=
   *         metadata 'export' stringLiteral combinator*';'
   */
  ExportDirective _parseExportDirective(CommentAndMetadata commentAndMetadata) {
    Token exportKeyword = _expectKeyword(Keyword.EXPORT);
    StringLiteral libraryUri = _parseUri();
    List<Combinator> combinators = _parseCombinators();
    Token semicolon = _expectSemicolon();
    return new ExportDirective(commentAndMetadata.comment,
        commentAndMetadata.metadata, exportKeyword, libraryUri, combinators,
        semicolon);
  }

  /**
   * Parse a list of expressions. Return the expression that was parsed.
   *
   *     expressionList ::=
   *         expression (',' expression)*
   */
  List<Expression> _parseExpressionList() {
    List<Expression> expressions = new List<Expression>();
    expressions.add(parseExpression2());
    while (_optional(TokenType.COMMA)) {
      expressions.add(parseExpression2());
    }
    return expressions;
  }

  /**
   * Parse the 'final', 'const', 'var' or type preceding a variable declaration.
   * The [optional] is `true` if the keyword and type are optional. Return the
   * 'final', 'const', 'var' or type that was parsed.
   *
   *     finalConstVarOrType ::=
   *         'final' type?
   *       | 'const' type?
   *       | 'var'
   *       | type
   */
  FinalConstVarOrType _parseFinalConstVarOrType(bool optional) {
    Token keyword = null;
    TypeName type = null;
    if (_matchesKeyword(Keyword.FINAL) || _matchesKeyword(Keyword.CONST)) {
      keyword = getAndAdvance();
      if (_isTypedIdentifier(_currentToken)) {
        type = parseTypeName();
      }
    } else if (_matchesKeyword(Keyword.VAR)) {
      keyword = getAndAdvance();
    } else {
      if (_isTypedIdentifier(_currentToken)) {
        type = parseReturnType();
      } else if (!optional) {
        _reportErrorForCurrentToken(
            ParserErrorCode.MISSING_CONST_FINAL_VAR_OR_TYPE);
      }
    }
    return new FinalConstVarOrType(keyword, type);
  }

  /**
   * Parse a formal parameter. At most one of `isOptional` and `isNamed` can be
   * `true`. The [kind] is the kind of parameter being expected based on the
   * presence or absence of group delimiters. Return the formal parameter that
   * was parsed.
   *
   *     defaultFormalParameter ::=
   *         normalFormalParameter ('=' expression)?
   *
   *     defaultNamedParameter ::=
   *         normalFormalParameter (':' expression)?
   */
  FormalParameter _parseFormalParameter(ParameterKind kind) {
    NormalFormalParameter parameter = parseNormalFormalParameter();
    if (_matches(TokenType.EQ)) {
      Token seperator = getAndAdvance();
      Expression defaultValue = parseExpression2();
      if (kind == ParameterKind.NAMED) {
        _reportErrorForToken(
            ParserErrorCode.WRONG_SEPARATOR_FOR_NAMED_PARAMETER, seperator);
      } else if (kind == ParameterKind.REQUIRED) {
        _reportErrorForNode(
            ParserErrorCode.POSITIONAL_PARAMETER_OUTSIDE_GROUP, parameter);
      }
      return new DefaultFormalParameter(
          parameter, kind, seperator, defaultValue);
    } else if (_matches(TokenType.COLON)) {
      Token seperator = getAndAdvance();
      Expression defaultValue = parseExpression2();
      if (kind == ParameterKind.POSITIONAL) {
        _reportErrorForToken(
            ParserErrorCode.WRONG_SEPARATOR_FOR_POSITIONAL_PARAMETER,
            seperator);
      } else if (kind == ParameterKind.REQUIRED) {
        _reportErrorForNode(
            ParserErrorCode.NAMED_PARAMETER_OUTSIDE_GROUP, parameter);
      }
      return new DefaultFormalParameter(
          parameter, kind, seperator, defaultValue);
    } else if (kind != ParameterKind.REQUIRED) {
      return new DefaultFormalParameter(parameter, kind, null, null);
    }
    return parameter;
  }

  /**
   * Parse a for statement. Return the for statement that was parsed.
   *
   *     forStatement ::=
   *         'for' '(' forLoopParts ')' statement
   *
   *     forLoopParts ::=
   *         forInitializerStatement expression? ';' expressionList?
   *       | declaredIdentifier 'in' expression
   *       | identifier 'in' expression
   *
   *     forInitializerStatement ::=
   *         localVariableDeclaration ';'
   *       | expression? ';'
   */
  Statement _parseForStatement() {
    bool wasInLoop = _inLoop;
    _inLoop = true;
    try {
      Token awaitKeyword = null;
      if (_matchesString(_AWAIT)) {
        awaitKeyword = getAndAdvance();
      }
      Token forKeyword = _expectKeyword(Keyword.FOR);
      Token leftParenthesis = _expect(TokenType.OPEN_PAREN);
      VariableDeclarationList variableList = null;
      Expression initialization = null;
      if (!_matches(TokenType.SEMICOLON)) {
        CommentAndMetadata commentAndMetadata = _parseCommentAndMetadata();
        if (_matchesIdentifier() &&
            (_tokenMatchesKeyword(_peek(), Keyword.IN) ||
                _tokenMatches(_peek(), TokenType.COLON))) {
          List<VariableDeclaration> variables = new List<VariableDeclaration>();
          SimpleIdentifier variableName = parseSimpleIdentifier();
          variables.add(new VariableDeclaration(variableName, null, null));
          variableList = new VariableDeclarationList(commentAndMetadata.comment,
              commentAndMetadata.metadata, null, null, variables);
        } else if (_isInitializedVariableDeclaration()) {
          variableList =
              _parseVariableDeclarationListAfterMetadata(commentAndMetadata);
        } else {
          initialization = parseExpression2();
        }
        if (_matchesKeyword(Keyword.IN) || _matches(TokenType.COLON)) {
          if (_matches(TokenType.COLON)) {
            _reportErrorForCurrentToken(ParserErrorCode.COLON_IN_PLACE_OF_IN);
          }
          DeclaredIdentifier loopVariable = null;
          SimpleIdentifier identifier = null;
          if (variableList == null) {
            // We found: <expression> 'in'
            _reportErrorForCurrentToken(
                ParserErrorCode.MISSING_VARIABLE_IN_FOR_EACH);
          } else {
            NodeList<VariableDeclaration> variables = variableList.variables;
            if (variables.length > 1) {
              _reportErrorForCurrentToken(
                  ParserErrorCode.MULTIPLE_VARIABLES_IN_FOR_EACH,
                  [variables.length.toString()]);
            }
            VariableDeclaration variable = variables[0];
            if (variable.initializer != null) {
              _reportErrorForCurrentToken(
                  ParserErrorCode.INITIALIZED_VARIABLE_IN_FOR_EACH);
            }
            Token keyword = variableList.keyword;
            TypeName type = variableList.type;
            if (keyword != null || type != null) {
              loopVariable = new DeclaredIdentifier(commentAndMetadata.comment,
                  commentAndMetadata.metadata, keyword, type, variable.name);
            } else {
              if (!commentAndMetadata.metadata.isEmpty) {
                // TODO(jwren) metadata isn't allowed before the identifier in
                // "identifier in expression", add warning if commentAndMetadata
                // has content
              }
              identifier = variable.name;
            }
          }
          Token inKeyword = getAndAdvance();
          Expression iterator = parseExpression2();
          Token rightParenthesis = _expect(TokenType.CLOSE_PAREN);
          Statement body = parseStatement2();
          if (loopVariable == null) {
            return new ForEachStatement.withReference(awaitKeyword, forKeyword,
                leftParenthesis, identifier, inKeyword, iterator,
                rightParenthesis, body);
          }
          return new ForEachStatement.withDeclaration(awaitKeyword, forKeyword,
              leftParenthesis, loopVariable, inKeyword, iterator,
              rightParenthesis, body);
        }
      }
      if (awaitKeyword != null) {
        _reportErrorForToken(
            ParserErrorCode.INVALID_AWAIT_IN_FOR, awaitKeyword);
      }
      Token leftSeparator = _expect(TokenType.SEMICOLON);
      Expression condition = null;
      if (!_matches(TokenType.SEMICOLON)) {
        condition = parseExpression2();
      }
      Token rightSeparator = _expect(TokenType.SEMICOLON);
      List<Expression> updaters = null;
      if (!_matches(TokenType.CLOSE_PAREN)) {
        updaters = _parseExpressionList();
      }
      Token rightParenthesis = _expect(TokenType.CLOSE_PAREN);
      Statement body = parseStatement2();
      return new ForStatement(forKeyword, leftParenthesis, variableList,
          initialization, leftSeparator, condition, rightSeparator, updaters,
          rightParenthesis, body);
    } finally {
      _inLoop = wasInLoop;
    }
  }

  /**
   * Parse a function body. The [mayBeEmpty] is `true` if the function body is
   * allowed to be empty. The [emptyErrorCode] is the error code to report if
   * function body expected, but not found. The [inExpression] is `true` if the
   * function body is being parsed as part of an expression and therefore does
   * not have a terminating semicolon. Return the function body that was parsed.
   *
   *     functionBody ::=
   *         '=>' expression ';'
   *       | block
   *
   *     functionExpressionBody ::=
   *         '=>' expression
   *       | block
   */
  FunctionBody _parseFunctionBody(
      bool mayBeEmpty, ParserErrorCode emptyErrorCode, bool inExpression) {
    bool wasInAsync = _inAsync;
    bool wasInGenerator = _inGenerator;
    bool wasInLoop = _inLoop;
    bool wasInSwitch = _inSwitch;
    _inAsync = false;
    _inGenerator = false;
    _inLoop = false;
    _inSwitch = false;
    try {
      if (_matches(TokenType.SEMICOLON)) {
        if (!mayBeEmpty) {
          _reportErrorForCurrentToken(emptyErrorCode);
        }
        return new EmptyFunctionBody(getAndAdvance());
      } else if (_matchesString(_NATIVE)) {
        Token nativeToken = getAndAdvance();
        StringLiteral stringLiteral = null;
        if (_matches(TokenType.STRING)) {
          stringLiteral = parseStringLiteral();
        }
        return new NativeFunctionBody(
            nativeToken, stringLiteral, _expect(TokenType.SEMICOLON));
      }
      Token keyword = null;
      Token star = null;
      if (_matchesString(ASYNC)) {
        keyword = getAndAdvance();
        if (_matches(TokenType.STAR)) {
          star = getAndAdvance();
          _inGenerator = true;
        }
        _inAsync = true;
      } else if (_matchesString(SYNC)) {
        keyword = getAndAdvance();
        if (_matches(TokenType.STAR)) {
          star = getAndAdvance();
          _inGenerator = true;
        }
      }
      if (_matches(TokenType.FUNCTION)) {
        if (keyword != null) {
          if (!_tokenMatchesString(keyword, ASYNC)) {
            _reportErrorForToken(ParserErrorCode.INVALID_SYNC, keyword);
            keyword = null;
          } else if (star != null) {
            _reportErrorForToken(
                ParserErrorCode.INVALID_STAR_AFTER_ASYNC, star);
          }
        }
        Token functionDefinition = getAndAdvance();
        if (_matchesKeyword(Keyword.RETURN)) {
          _reportErrorForToken(ParserErrorCode.UNEXPECTED_TOKEN, _currentToken,
              [_currentToken.lexeme]);
          _advance();
        }
        Expression expression = parseExpression2();
        Token semicolon = null;
        if (!inExpression) {
          semicolon = _expect(TokenType.SEMICOLON);
        }
        if (!_parseFunctionBodies) {
          return new EmptyFunctionBody(
              _createSyntheticToken(TokenType.SEMICOLON));
        }
        return new ExpressionFunctionBody(
            keyword, functionDefinition, expression, semicolon);
      } else if (_matches(TokenType.OPEN_CURLY_BRACKET)) {
        if (keyword != null) {
          if (_tokenMatchesString(keyword, SYNC) && star == null) {
            _reportErrorForToken(
                ParserErrorCode.MISSING_STAR_AFTER_SYNC, keyword);
          }
        }
        if (!_parseFunctionBodies) {
          _skipBlock();
          return new EmptyFunctionBody(
              _createSyntheticToken(TokenType.SEMICOLON));
        }
        return new BlockFunctionBody(keyword, star, parseBlock());
      } else {
        // Invalid function body
        _reportErrorForCurrentToken(emptyErrorCode);
        return new EmptyFunctionBody(
            _createSyntheticToken(TokenType.SEMICOLON));
      }
    } finally {
      _inAsync = wasInAsync;
      _inGenerator = wasInGenerator;
      _inLoop = wasInLoop;
      _inSwitch = wasInSwitch;
    }
  }

  /**
   * Parse a function declaration. The [commentAndMetadata] is the documentation
   * comment and metadata to be associated with the declaration. The
   * [externalKeyword] is the 'external' keyword, or `null` if the function is
   * not external. The [returnType] is the return type, or `null` if there is no
   * return type. The [isStatement] is `true` if the function declaration is
   * being parsed as a statement. Return the function declaration that was
   * parsed.
   *
   *     functionDeclaration ::=
   *         functionSignature functionBody
   *       | returnType? getOrSet identifier formalParameterList functionBody
   */
  FunctionDeclaration _parseFunctionDeclaration(
      CommentAndMetadata commentAndMetadata, Token externalKeyword,
      TypeName returnType) {
    Token keyword = null;
    bool isGetter = false;
    if (_matchesKeyword(Keyword.GET) &&
        !_tokenMatches(_peek(), TokenType.OPEN_PAREN)) {
      keyword = getAndAdvance();
      isGetter = true;
    } else if (_matchesKeyword(Keyword.SET) &&
        !_tokenMatches(_peek(), TokenType.OPEN_PAREN)) {
      keyword = getAndAdvance();
    }
    SimpleIdentifier name = parseSimpleIdentifier();
    TypeParameterList typeParameters = null;
    if (parseGenericMethods && _matches(TokenType.LT)) {
      typeParameters = parseTypeParameterList();
    }
    FormalParameterList parameters = null;
    if (!isGetter) {
      if (_matches(TokenType.OPEN_PAREN)) {
        parameters = parseFormalParameterList();
        _validateFormalParameterList(parameters);
      } else {
        _reportErrorForCurrentToken(
            ParserErrorCode.MISSING_FUNCTION_PARAMETERS);
        parameters = new FormalParameterList(
            _createSyntheticToken(TokenType.OPEN_PAREN), null, null, null,
            _createSyntheticToken(TokenType.CLOSE_PAREN));
      }
    } else if (_matches(TokenType.OPEN_PAREN)) {
      _reportErrorForCurrentToken(ParserErrorCode.GETTER_WITH_PARAMETERS);
      parseFormalParameterList();
    }
    FunctionBody body;
    if (externalKeyword == null) {
      body = _parseFunctionBody(
          false, ParserErrorCode.MISSING_FUNCTION_BODY, false);
    } else {
      body = new EmptyFunctionBody(_expect(TokenType.SEMICOLON));
    }
//        if (!isStatement && matches(TokenType.SEMICOLON)) {
//          // TODO(brianwilkerson) Improve this error message.
//          reportError(ParserErrorCode.UNEXPECTED_TOKEN, currentToken.getLexeme());
//          advance();
//        }
    return new FunctionDeclaration(commentAndMetadata.comment,
        commentAndMetadata.metadata, externalKeyword, returnType, keyword, name,
        new FunctionExpression(typeParameters, parameters, body));
  }

  /**
   * Parse a function declaration statement. Return the function declaration
   * statement that was parsed.
   *
   *     functionDeclarationStatement ::=
   *         functionSignature functionBody
   */
  Statement _parseFunctionDeclarationStatement() {
    Modifiers modifiers = _parseModifiers();
    _validateModifiersForFunctionDeclarationStatement(modifiers);
    return _parseFunctionDeclarationStatementAfterReturnType(
        _parseCommentAndMetadata(), _parseOptionalReturnType());
  }

  /**
   * Parse a function declaration statement. The [commentAndMetadata] is the
   * documentation comment and metadata to be associated with the declaration.
   * The [returnType] is the return type, or `null` if there is no return type.
   * Return the function declaration statement that was parsed.
   *
   *     functionDeclarationStatement ::=
   *         functionSignature functionBody
   */
  Statement _parseFunctionDeclarationStatementAfterReturnType(
      CommentAndMetadata commentAndMetadata, TypeName returnType) {
    FunctionDeclaration declaration =
        _parseFunctionDeclaration(commentAndMetadata, null, returnType);
    Token propertyKeyword = declaration.propertyKeyword;
    if (propertyKeyword != null) {
      if ((propertyKeyword as KeywordToken).keyword == Keyword.GET) {
        _reportErrorForToken(
            ParserErrorCode.GETTER_IN_FUNCTION, propertyKeyword);
      } else {
        _reportErrorForToken(
            ParserErrorCode.SETTER_IN_FUNCTION, propertyKeyword);
      }
    }
    return new FunctionDeclarationStatement(declaration);
  }

  /**
   * Parse a function type alias. The [commentAndMetadata] is the metadata to be
   * associated with the member. The [keyword] is the token representing the
   * 'typedef' keyword. Return the function type alias that was parsed.
   *
   *     functionTypeAlias ::=
   *         functionPrefix typeParameterList? formalParameterList ';'
   *
   *     functionPrefix ::=
   *         returnType? name
   */
  FunctionTypeAlias _parseFunctionTypeAlias(
      CommentAndMetadata commentAndMetadata, Token keyword) {
    TypeName returnType = null;
    if (hasReturnTypeInTypeAlias) {
      returnType = parseReturnType();
    }
    SimpleIdentifier name = parseSimpleIdentifier();
    TypeParameterList typeParameters = null;
    if (_matches(TokenType.LT)) {
      typeParameters = parseTypeParameterList();
    }
    if (_matches(TokenType.SEMICOLON) || _matches(TokenType.EOF)) {
      _reportErrorForCurrentToken(ParserErrorCode.MISSING_TYPEDEF_PARAMETERS);
      FormalParameterList parameters = new FormalParameterList(
          _createSyntheticToken(TokenType.OPEN_PAREN), null, null, null,
          _createSyntheticToken(TokenType.CLOSE_PAREN));
      Token semicolon = _expect(TokenType.SEMICOLON);
      return new FunctionTypeAlias(commentAndMetadata.comment,
          commentAndMetadata.metadata, keyword, returnType, name,
          typeParameters, parameters, semicolon);
    } else if (!_matches(TokenType.OPEN_PAREN)) {
      _reportErrorForCurrentToken(ParserErrorCode.MISSING_TYPEDEF_PARAMETERS);
      // TODO(brianwilkerson) Recover from this error. At the very least we
      // should skip to the start of the next valid compilation unit member,
      // allowing for the possibility of finding the typedef parameters before
      // that point.
      return new FunctionTypeAlias(commentAndMetadata.comment,
          commentAndMetadata.metadata, keyword, returnType, name,
          typeParameters, new FormalParameterList(
              _createSyntheticToken(TokenType.OPEN_PAREN), null, null, null,
              _createSyntheticToken(TokenType.CLOSE_PAREN)),
          _createSyntheticToken(TokenType.SEMICOLON));
    }
    FormalParameterList parameters = parseFormalParameterList();
    _validateFormalParameterList(parameters);
    Token semicolon = _expect(TokenType.SEMICOLON);
    return new FunctionTypeAlias(commentAndMetadata.comment,
        commentAndMetadata.metadata, keyword, returnType, name, typeParameters,
        parameters, semicolon);
  }

  /**
   * Parse a getter. The [commentAndMetadata] is the documentation comment and
   * metadata to be associated with the declaration. The externalKeyword] is the
   * 'external' token. The staticKeyword] is the static keyword, or `null` if
   * the getter is not static. The [returnType] the return type that has already
   * been parsed, or `null` if there was no return type. Return the getter that
   * was parsed.
   *
   *     getter ::=
   *         getterSignature functionBody?
   *
   *     getterSignature ::=
   *         'external'? 'static'? returnType? 'get' identifier
   */
  MethodDeclaration _parseGetter(CommentAndMetadata commentAndMetadata,
      Token externalKeyword, Token staticKeyword, TypeName returnType) {
    Token propertyKeyword = _expectKeyword(Keyword.GET);
    SimpleIdentifier name = parseSimpleIdentifier();
    if (_matches(TokenType.OPEN_PAREN) &&
        _tokenMatches(_peek(), TokenType.CLOSE_PAREN)) {
      _reportErrorForCurrentToken(ParserErrorCode.GETTER_WITH_PARAMETERS);
      _advance();
      _advance();
    }
    FunctionBody body = _parseFunctionBody(
        externalKeyword != null || staticKeyword == null,
        ParserErrorCode.STATIC_GETTER_WITHOUT_BODY, false);
    if (externalKeyword != null && body is! EmptyFunctionBody) {
      _reportErrorForCurrentToken(ParserErrorCode.EXTERNAL_GETTER_WITH_BODY);
    }
    return new MethodDeclaration(commentAndMetadata.comment,
        commentAndMetadata.metadata, externalKeyword, staticKeyword, returnType,
        propertyKeyword, null, name, null, null, body);
  }

  /**
   * Parse a list of identifiers. Return the list of identifiers that were
   * parsed.
   *
   *     identifierList ::=
   *         identifier (',' identifier)*
   */
  List<SimpleIdentifier> _parseIdentifierList() {
    List<SimpleIdentifier> identifiers = new List<SimpleIdentifier>();
    identifiers.add(parseSimpleIdentifier());
    while (_matches(TokenType.COMMA)) {
      _advance();
      identifiers.add(parseSimpleIdentifier());
    }
    return identifiers;
  }

  /**
   * Parse an if statement. Return the if statement that was parsed.
   *
   *     ifStatement ::=
   *         'if' '(' expression ')' statement ('else' statement)?
   */
  Statement _parseIfStatement() {
    Token ifKeyword = _expectKeyword(Keyword.IF);
    Token leftParenthesis = _expect(TokenType.OPEN_PAREN);
    Expression condition = parseExpression2();
    Token rightParenthesis = _expect(TokenType.CLOSE_PAREN);
    Statement thenStatement = parseStatement2();
    Token elseKeyword = null;
    Statement elseStatement = null;
    if (_matchesKeyword(Keyword.ELSE)) {
      elseKeyword = getAndAdvance();
      elseStatement = parseStatement2();
    }
    return new IfStatement(ifKeyword, leftParenthesis, condition,
        rightParenthesis, thenStatement, elseKeyword, elseStatement);
  }

  /**
   * Parse an import directive. The [commentAndMetadata] is the metadata to be
   * associated with the directive. Return the import directive that was parsed.
   *
   *     importDirective ::=
   *         metadata 'import' stringLiteral (deferred)? ('as' identifier)? combinator*';'
   */
  ImportDirective _parseImportDirective(CommentAndMetadata commentAndMetadata) {
    Token importKeyword = _expectKeyword(Keyword.IMPORT);
    StringLiteral libraryUri = _parseUri();
    Token deferredToken = null;
    Token asToken = null;
    SimpleIdentifier prefix = null;
    if (_matchesKeyword(Keyword.DEFERRED)) {
      deferredToken = getAndAdvance();
    }
    if (_matchesKeyword(Keyword.AS)) {
      asToken = getAndAdvance();
      prefix = parseSimpleIdentifier();
    } else if (deferredToken != null) {
      _reportErrorForCurrentToken(
          ParserErrorCode.MISSING_PREFIX_IN_DEFERRED_IMPORT);
    } else if (!_matches(TokenType.SEMICOLON) &&
        !_matchesString(_SHOW) &&
        !_matchesString(_HIDE)) {
      Token nextToken = _peek();
      if (_tokenMatchesKeyword(nextToken, Keyword.AS) ||
          _tokenMatchesString(nextToken, _SHOW) ||
          _tokenMatchesString(nextToken, _HIDE)) {
        _reportErrorForCurrentToken(
            ParserErrorCode.UNEXPECTED_TOKEN, [_currentToken]);
        _advance();
        if (_matchesKeyword(Keyword.AS)) {
          asToken = getAndAdvance();
          prefix = parseSimpleIdentifier();
        }
      }
    }
    List<Combinator> combinators = _parseCombinators();
    Token semicolon = _expectSemicolon();
    return new ImportDirective(commentAndMetadata.comment,
        commentAndMetadata.metadata, importKeyword, libraryUri, deferredToken,
        asToken, prefix, combinators, semicolon);
  }

  /**
   * Parse a list of initialized identifiers. The [commentAndMetadata] is the
   * documentation comment and metadata to be associated with the declaration.
   * The [staticKeyword] is the static keyword, or `null` if the getter is not
   * static. The [keyword] is the token representing the 'final', 'const' or
   * 'var' keyword, or `null` if there is no keyword. The [type] is the type
   * that has already been parsed, or `null` if 'var' was provided. Return the
   * getter that was parsed.
   *
   *     ?? ::=
   *         'static'? ('var' | type) initializedIdentifierList ';'
   *       | 'final' type? initializedIdentifierList ';'
   *
   *     initializedIdentifierList ::=
   *         initializedIdentifier (',' initializedIdentifier)*
   *
   *     initializedIdentifier ::=
   *         identifier ('=' expression)?
   */
  FieldDeclaration _parseInitializedIdentifierList(
      CommentAndMetadata commentAndMetadata, Token staticKeyword, Token keyword,
      TypeName type) {
    VariableDeclarationList fieldList =
        _parseVariableDeclarationListAfterType(null, keyword, type);
    return new FieldDeclaration(commentAndMetadata.comment,
        commentAndMetadata.metadata, staticKeyword, fieldList,
        _expect(TokenType.SEMICOLON));
  }

  /**
   * Parse an instance creation expression. The [keyword] is the 'new' or
   * 'const' keyword that introduces the expression. Return the instance
   * creation expression that was parsed.
   *
   *     instanceCreationExpression ::=
   *         ('new' | 'const') type ('.' identifier)? argumentList
   */
  InstanceCreationExpression _parseInstanceCreationExpression(Token keyword) {
    ConstructorName constructorName = parseConstructorName();
    ArgumentList argumentList = parseArgumentList();
    return new InstanceCreationExpression(
        keyword, constructorName, argumentList);
  }

  /**
   * Parse a library directive. The [commentAndMetadata] is the metadata to be
   * associated with the directive. Return the library directive that was
   * parsed.
   *
   *     libraryDirective ::=
   *         metadata 'library' identifier ';'
   */
  LibraryDirective _parseLibraryDirective(
      CommentAndMetadata commentAndMetadata) {
    Token keyword = _expectKeyword(Keyword.LIBRARY);
    LibraryIdentifier libraryName = _parseLibraryName(
        ParserErrorCode.MISSING_NAME_IN_LIBRARY_DIRECTIVE, keyword);
    Token semicolon = _expect(TokenType.SEMICOLON);
    return new LibraryDirective(commentAndMetadata.comment,
        commentAndMetadata.metadata, keyword, libraryName, semicolon);
  }

  /**
   * Parse a library name. The [missingNameError] is the error code to be used
   * if the library name is missing. The [missingNameToken] is the token
   * associated with the error produced if the library name is missing. Return
   * the library name that was parsed.
   *
   *     libraryName ::=
   *         libraryIdentifier
   */
  LibraryIdentifier _parseLibraryName(
      ParserErrorCode missingNameError, Token missingNameToken) {
    if (_matchesIdentifier()) {
      return parseLibraryIdentifier();
    } else if (_matches(TokenType.STRING)) {
      // TODO(brianwilkerson) Recovery: This should be extended to handle
      // arbitrary tokens until we can find a token that can start a compilation
      // unit member.
      StringLiteral string = parseStringLiteral();
      _reportErrorForNode(ParserErrorCode.NON_IDENTIFIER_LIBRARY_NAME, string);
    } else {
      _reportErrorForToken(missingNameError, missingNameToken);
    }
    List<SimpleIdentifier> components = new List<SimpleIdentifier>();
    components.add(_createSyntheticIdentifier());
    return new LibraryIdentifier(components);
  }

  /**
   * Parse a list literal. The [modifier] is the 'const' modifier appearing
   * before the literal, or `null` if there is no modifier. The [typeArguments]
   * is the type arguments appearing before the literal, or `null` if there are
   * no type arguments. Return the list literal that was parsed.
   *
   *     listLiteral ::=
   *         'const'? typeArguments? '[' (expressionList ','?)? ']'
   */
  ListLiteral _parseListLiteral(
      Token modifier, TypeArgumentList typeArguments) {
    // may be empty list literal
    if (_matches(TokenType.INDEX)) {
      BeginToken leftBracket = _createToken(
          _currentToken, TokenType.OPEN_SQUARE_BRACKET, isBegin: true);
      Token rightBracket =
          new Token(TokenType.CLOSE_SQUARE_BRACKET, _currentToken.offset + 1);
      leftBracket.endToken = rightBracket;
      rightBracket.setNext(_currentToken.next);
      leftBracket.setNext(rightBracket);
      _currentToken.previous.setNext(leftBracket);
      _currentToken = _currentToken.next;
      return new ListLiteral(
          modifier, typeArguments, leftBracket, null, rightBracket);
    }
    // open
    Token leftBracket = _expect(TokenType.OPEN_SQUARE_BRACKET);
    if (_matches(TokenType.CLOSE_SQUARE_BRACKET)) {
      return new ListLiteral(
          modifier, typeArguments, leftBracket, null, getAndAdvance());
    }
    bool wasInInitializer = _inInitializer;
    _inInitializer = false;
    try {
      List<Expression> elements = new List<Expression>();
      elements.add(parseExpression2());
      while (_optional(TokenType.COMMA)) {
        if (_matches(TokenType.CLOSE_SQUARE_BRACKET)) {
          return new ListLiteral(
              modifier, typeArguments, leftBracket, elements, getAndAdvance());
        }
        elements.add(parseExpression2());
      }
      Token rightBracket = _expect(TokenType.CLOSE_SQUARE_BRACKET);
      return new ListLiteral(
          modifier, typeArguments, leftBracket, elements, rightBracket);
    } finally {
      _inInitializer = wasInInitializer;
    }
  }

  /**
   * Parse a list or map literal. The [modifier] is the 'const' modifier
   * appearing before the literal, or `null` if there is no modifier. Return the
   * list or map literal that was parsed.
   *
   *     listOrMapLiteral ::=
   *         listLiteral
   *       | mapLiteral
   */
  TypedLiteral _parseListOrMapLiteral(Token modifier) {
    TypeArgumentList typeArguments = null;
    if (_matches(TokenType.LT)) {
      typeArguments = parseTypeArgumentList();
    }
    if (_matches(TokenType.OPEN_CURLY_BRACKET)) {
      return _parseMapLiteral(modifier, typeArguments);
    } else if (_matches(TokenType.OPEN_SQUARE_BRACKET) ||
        _matches(TokenType.INDEX)) {
      return _parseListLiteral(modifier, typeArguments);
    }
    _reportErrorForCurrentToken(ParserErrorCode.EXPECTED_LIST_OR_MAP_LITERAL);
    return new ListLiteral(modifier, typeArguments,
        _createSyntheticToken(TokenType.OPEN_SQUARE_BRACKET), null,
        _createSyntheticToken(TokenType.CLOSE_SQUARE_BRACKET));
  }

  /**
   * Parse a logical and expression. Return the logical and expression that was
   * parsed.
   *
   *     logicalAndExpression ::=
   *         equalityExpression ('&&' equalityExpression)*
   */
  Expression _parseLogicalAndExpression() {
    Expression expression = _parseEqualityExpression();
    while (_matches(TokenType.AMPERSAND_AMPERSAND)) {
      Token operator = getAndAdvance();
      expression = new BinaryExpression(
          expression, operator, _parseEqualityExpression());
    }
    return expression;
  }

  /**
   * Parse a map literal. The [modifier] is the 'const' modifier appearing
   * before the literal, or `null` if there is no modifier. The [typeArguments]
   * is the type arguments that were declared, or `null` if there are no type
   * arguments. Return the map literal that was parsed.
   *
   *     mapLiteral ::=
   *         'const'? typeArguments? '{' (mapLiteralEntry (',' mapLiteralEntry)* ','?)? '}'
   */
  MapLiteral _parseMapLiteral(Token modifier, TypeArgumentList typeArguments) {
    Token leftBracket = _expect(TokenType.OPEN_CURLY_BRACKET);
    List<MapLiteralEntry> entries = new List<MapLiteralEntry>();
    if (_matches(TokenType.CLOSE_CURLY_BRACKET)) {
      return new MapLiteral(
          modifier, typeArguments, leftBracket, entries, getAndAdvance());
    }
    bool wasInInitializer = _inInitializer;
    _inInitializer = false;
    try {
      entries.add(parseMapLiteralEntry());
      while (_optional(TokenType.COMMA)) {
        if (_matches(TokenType.CLOSE_CURLY_BRACKET)) {
          return new MapLiteral(
              modifier, typeArguments, leftBracket, entries, getAndAdvance());
        }
        entries.add(parseMapLiteralEntry());
      }
      Token rightBracket = _expect(TokenType.CLOSE_CURLY_BRACKET);
      return new MapLiteral(
          modifier, typeArguments, leftBracket, entries, rightBracket);
    } finally {
      _inInitializer = wasInInitializer;
    }
  }

  /**
   * Parse a method declaration. The [commentAndMetadata] is the documentation
   * comment and metadata to be associated with the declaration. The
   * [externalKeyword] is the 'external' token. The [staticKeyword] is the
   * static keyword, or `null` if the getter is not static. The [returnType] is
   * the return type of the method. The [name] is the name of the method. The
   * [parameters] is the parameters to the method. Return the method declaration
   * that was parsed.
   *
   *     functionDeclaration ::=
   *         ('external' 'static'?)? functionSignature functionBody
   *       | 'external'? functionSignature ';'
   */
  MethodDeclaration _parseMethodDeclarationAfterParameters(
      CommentAndMetadata commentAndMetadata, Token externalKeyword,
      Token staticKeyword, TypeName returnType, SimpleIdentifier name,
      TypeParameterList typeParameters, FormalParameterList parameters) {
    FunctionBody body = _parseFunctionBody(
        externalKeyword != null || staticKeyword == null,
        ParserErrorCode.MISSING_FUNCTION_BODY, false);
    if (externalKeyword != null) {
      if (body is! EmptyFunctionBody) {
        _reportErrorForNode(ParserErrorCode.EXTERNAL_METHOD_WITH_BODY, body);
      }
    } else if (staticKeyword != null) {
      if (body is EmptyFunctionBody && _parseFunctionBodies) {
        _reportErrorForNode(ParserErrorCode.ABSTRACT_STATIC_METHOD, body);
      }
    }
    return new MethodDeclaration(commentAndMetadata.comment,
        commentAndMetadata.metadata, externalKeyword, staticKeyword, returnType,
        null, null, name, typeParameters, parameters, body);
  }

  /**
   * Parse a method declaration. The [commentAndMetadata] is the documentation
   * comment and metadata to be associated with the declaration. The
   * [externalKeyword] is the 'external' token. The [staticKeyword] is the
   * static keyword, or `null` if the getter is not static. The [returnType] is
   * the return type of the method. Return the method declaration that was
   * parsed.
   *
   *     functionDeclaration ::=
   *         'external'? 'static'? functionSignature functionBody
   *       | 'external'? functionSignature ';'
   */
  MethodDeclaration _parseMethodDeclarationAfterReturnType(
      CommentAndMetadata commentAndMetadata, Token externalKeyword,
      Token staticKeyword, TypeName returnType) {
    SimpleIdentifier methodName = parseSimpleIdentifier();
    TypeParameterList typeParameters = null;
    if (parseGenericMethods && _matches(TokenType.LT)) {
      typeParameters = parseTypeParameterList();
    }
    FormalParameterList parameters;
    if (!_matches(TokenType.OPEN_PAREN) &&
        (_matches(TokenType.OPEN_CURLY_BRACKET) ||
            _matches(TokenType.FUNCTION))) {
      _reportErrorForToken(
          ParserErrorCode.MISSING_METHOD_PARAMETERS, _currentToken.previous);
      parameters = new FormalParameterList(
          _createSyntheticToken(TokenType.OPEN_PAREN), null, null, null,
          _createSyntheticToken(TokenType.CLOSE_PAREN));
    } else {
      parameters = parseFormalParameterList();
    }
    _validateFormalParameterList(parameters);
    return _parseMethodDeclarationAfterParameters(commentAndMetadata,
        externalKeyword, staticKeyword, returnType, methodName, typeParameters,
        parameters);
  }

  /**
   * Parse the modifiers preceding a declaration. This method allows the
   * modifiers to appear in any order but does generate errors for duplicated
   * modifiers. Checks for other problems, such as having the modifiers appear
   * in the wrong order or specifying both 'const' and 'final', are reported in
   * one of the methods whose name is prefixed with `validateModifiersFor`.
   * Return the modifiers that were parsed.
   *
   *     modifiers ::=
   *         ('abstract' | 'const' | 'external' | 'factory' | 'final' | 'static' | 'var')*
   */
  Modifiers _parseModifiers() {
    Modifiers modifiers = new Modifiers();
    bool progress = true;
    while (progress) {
      if (_tokenMatches(_peek(), TokenType.PERIOD) ||
          _tokenMatches(_peek(), TokenType.LT) ||
          _tokenMatches(_peek(), TokenType.OPEN_PAREN)) {
        return modifiers;
      }
      if (_matchesKeyword(Keyword.ABSTRACT)) {
        if (modifiers.abstractKeyword != null) {
          _reportErrorForCurrentToken(
              ParserErrorCode.DUPLICATED_MODIFIER, [_currentToken.lexeme]);
          _advance();
        } else {
          modifiers.abstractKeyword = getAndAdvance();
        }
      } else if (_matchesKeyword(Keyword.CONST)) {
        if (modifiers.constKeyword != null) {
          _reportErrorForCurrentToken(
              ParserErrorCode.DUPLICATED_MODIFIER, [_currentToken.lexeme]);
          _advance();
        } else {
          modifiers.constKeyword = getAndAdvance();
        }
      } else if (_matchesKeyword(Keyword.EXTERNAL) &&
          !_tokenMatches(_peek(), TokenType.PERIOD) &&
          !_tokenMatches(_peek(), TokenType.LT)) {
        if (modifiers.externalKeyword != null) {
          _reportErrorForCurrentToken(
              ParserErrorCode.DUPLICATED_MODIFIER, [_currentToken.lexeme]);
          _advance();
        } else {
          modifiers.externalKeyword = getAndAdvance();
        }
      } else if (_matchesKeyword(Keyword.FACTORY) &&
          !_tokenMatches(_peek(), TokenType.PERIOD) &&
          !_tokenMatches(_peek(), TokenType.LT)) {
        if (modifiers.factoryKeyword != null) {
          _reportErrorForCurrentToken(
              ParserErrorCode.DUPLICATED_MODIFIER, [_currentToken.lexeme]);
          _advance();
        } else {
          modifiers.factoryKeyword = getAndAdvance();
        }
      } else if (_matchesKeyword(Keyword.FINAL)) {
        if (modifiers.finalKeyword != null) {
          _reportErrorForCurrentToken(
              ParserErrorCode.DUPLICATED_MODIFIER, [_currentToken.lexeme]);
          _advance();
        } else {
          modifiers.finalKeyword = getAndAdvance();
        }
      } else if (_matchesKeyword(Keyword.STATIC) &&
          !_tokenMatches(_peek(), TokenType.PERIOD) &&
          !_tokenMatches(_peek(), TokenType.LT)) {
        if (modifiers.staticKeyword != null) {
          _reportErrorForCurrentToken(
              ParserErrorCode.DUPLICATED_MODIFIER, [_currentToken.lexeme]);
          _advance();
        } else {
          modifiers.staticKeyword = getAndAdvance();
        }
      } else if (_matchesKeyword(Keyword.VAR)) {
        if (modifiers.varKeyword != null) {
          _reportErrorForCurrentToken(
              ParserErrorCode.DUPLICATED_MODIFIER, [_currentToken.lexeme]);
          _advance();
        } else {
          modifiers.varKeyword = getAndAdvance();
        }
      } else {
        progress = false;
      }
    }
    return modifiers;
  }

  /**
   * Parse a multiplicative expression. Return the multiplicative expression
   * that was parsed.
   *
   *     multiplicativeExpression ::=
   *         unaryExpression (multiplicativeOperator unaryExpression)*
   *       | 'super' (multiplicativeOperator unaryExpression)+
   */
  Expression _parseMultiplicativeExpression() {
    Expression expression;
    if (_matchesKeyword(Keyword.SUPER) &&
        _currentToken.next.type.isMultiplicativeOperator) {
      expression = new SuperExpression(getAndAdvance());
    } else {
      expression = _parseUnaryExpression();
    }
    while (_currentToken.type.isMultiplicativeOperator) {
      Token operator = getAndAdvance();
      expression =
          new BinaryExpression(expression, operator, _parseUnaryExpression());
    }
    return expression;
  }

  /**
   * Parse a class native clause. Return the native clause that was parsed.
   *
   *     classNativeClause ::=
   *         'native' name
   */
  NativeClause _parseNativeClause() {
    Token keyword = getAndAdvance();
    StringLiteral name = parseStringLiteral();
    return new NativeClause(keyword, name);
  }

  /**
   * Parse a new expression. Return the new expression that was parsed.
   *
   *     newExpression ::=
   *         instanceCreationExpression
   */
  InstanceCreationExpression _parseNewExpression() =>
      _parseInstanceCreationExpression(_expectKeyword(Keyword.NEW));

  /**
   * Parse a non-labeled statement. Return the non-labeled statement that was
   * parsed.
   *
   *     nonLabeledStatement ::=
   *         block
   *       | assertStatement
   *       | breakStatement
   *       | continueStatement
   *       | doStatement
   *       | forStatement
   *       | ifStatement
   *       | returnStatement
   *       | switchStatement
   *       | tryStatement
   *       | whileStatement
   *       | variableDeclarationList ';'
   *       | expressionStatement
   *       | functionSignature functionBody
   */
  Statement _parseNonLabeledStatement() {
    // TODO(brianwilkerson) Pass the comment and metadata on where appropriate.
    CommentAndMetadata commentAndMetadata = _parseCommentAndMetadata();
    if (_matches(TokenType.OPEN_CURLY_BRACKET)) {
      if (_tokenMatches(_peek(), TokenType.STRING)) {
        Token afterString = _skipStringLiteral(_currentToken.next);
        if (afterString != null && afterString.type == TokenType.COLON) {
          return new ExpressionStatement(
              parseExpression2(), _expect(TokenType.SEMICOLON));
        }
      }
      return parseBlock();
    } else if (_matches(TokenType.KEYWORD) &&
        !(_currentToken as KeywordToken).keyword.isPseudoKeyword) {
      Keyword keyword = (_currentToken as KeywordToken).keyword;
      // TODO(jwren) compute some metrics to figure out a better order for this
      // if-then sequence to optimize performance
      if (keyword == Keyword.ASSERT) {
        return _parseAssertStatement();
      } else if (keyword == Keyword.BREAK) {
        return _parseBreakStatement();
      } else if (keyword == Keyword.CONTINUE) {
        return _parseContinueStatement();
      } else if (keyword == Keyword.DO) {
        return _parseDoStatement();
      } else if (keyword == Keyword.FOR) {
        return _parseForStatement();
      } else if (keyword == Keyword.IF) {
        return _parseIfStatement();
      } else if (keyword == Keyword.RETHROW) {
        return new ExpressionStatement(
            _parseRethrowExpression(), _expect(TokenType.SEMICOLON));
      } else if (keyword == Keyword.RETURN) {
        return _parseReturnStatement();
      } else if (keyword == Keyword.SWITCH) {
        return _parseSwitchStatement();
      } else if (keyword == Keyword.THROW) {
        return new ExpressionStatement(
            _parseThrowExpression(), _expect(TokenType.SEMICOLON));
      } else if (keyword == Keyword.TRY) {
        return _parseTryStatement();
      } else if (keyword == Keyword.WHILE) {
        return _parseWhileStatement();
      } else if (keyword == Keyword.VAR || keyword == Keyword.FINAL) {
        return _parseVariableDeclarationStatementAfterMetadata(
            commentAndMetadata);
      } else if (keyword == Keyword.VOID) {
        TypeName returnType = parseReturnType();
        if (_matchesIdentifier() &&
            _peek().matchesAny([
          TokenType.OPEN_PAREN,
          TokenType.OPEN_CURLY_BRACKET,
          TokenType.FUNCTION
        ])) {
          return _parseFunctionDeclarationStatementAfterReturnType(
              commentAndMetadata, returnType);
        } else {
          //
          // We have found an error of some kind. Try to recover.
          //
          if (_matchesIdentifier()) {
            if (_peek().matchesAny(
                [TokenType.EQ, TokenType.COMMA, TokenType.SEMICOLON])) {
              //
              // We appear to have a variable declaration with a type of "void".
              //
              _reportErrorForNode(ParserErrorCode.VOID_VARIABLE, returnType);
              return _parseVariableDeclarationStatementAfterMetadata(
                  commentAndMetadata);
            }
          } else if (_matches(TokenType.CLOSE_CURLY_BRACKET)) {
            //
            // We appear to have found an incomplete statement at the end of a
            // block. Parse it as a variable declaration.
            //
            return _parseVariableDeclarationStatementAfterType(
                commentAndMetadata, null, returnType);
          }
          _reportErrorForCurrentToken(ParserErrorCode.MISSING_STATEMENT);
          // TODO(brianwilkerson) Recover from this error.
          return new EmptyStatement(_createSyntheticToken(TokenType.SEMICOLON));
        }
      } else if (keyword == Keyword.CONST) {
        if (_peek().matchesAny([
          TokenType.LT,
          TokenType.OPEN_CURLY_BRACKET,
          TokenType.OPEN_SQUARE_BRACKET,
          TokenType.INDEX
        ])) {
          return new ExpressionStatement(
              parseExpression2(), _expect(TokenType.SEMICOLON));
        } else if (_tokenMatches(_peek(), TokenType.IDENTIFIER)) {
          Token afterType = _skipTypeName(_peek());
          if (afterType != null) {
            if (_tokenMatches(afterType, TokenType.OPEN_PAREN) ||
                (_tokenMatches(afterType, TokenType.PERIOD) &&
                    _tokenMatches(afterType.next, TokenType.IDENTIFIER) &&
                    _tokenMatches(afterType.next.next, TokenType.OPEN_PAREN))) {
              return new ExpressionStatement(
                  parseExpression2(), _expect(TokenType.SEMICOLON));
            }
          }
        }
        return _parseVariableDeclarationStatementAfterMetadata(
            commentAndMetadata);
      } else if (keyword == Keyword.NEW ||
          keyword == Keyword.TRUE ||
          keyword == Keyword.FALSE ||
          keyword == Keyword.NULL ||
          keyword == Keyword.SUPER ||
          keyword == Keyword.THIS) {
        return new ExpressionStatement(
            parseExpression2(), _expect(TokenType.SEMICOLON));
      } else {
        //
        // We have found an error of some kind. Try to recover.
        //
        _reportErrorForCurrentToken(ParserErrorCode.MISSING_STATEMENT);
        return new EmptyStatement(_createSyntheticToken(TokenType.SEMICOLON));
      }
    } else if (_inGenerator && _matchesString(_YIELD)) {
      return _parseYieldStatement();
    } else if (_inAsync && _matchesString(_AWAIT)) {
      if (_tokenMatchesKeyword(_peek(), Keyword.FOR)) {
        return _parseForStatement();
      }
      return new ExpressionStatement(
          parseExpression2(), _expect(TokenType.SEMICOLON));
    } else if (_matchesString(_AWAIT) &&
        _tokenMatchesKeyword(_peek(), Keyword.FOR)) {
      Token awaitToken = _currentToken;
      Statement statement = _parseForStatement();
      if (statement is! ForStatement) {
        _reportErrorForToken(
            CompileTimeErrorCode.ASYNC_FOR_IN_WRONG_CONTEXT, awaitToken);
      }
      return statement;
    } else if (_matches(TokenType.SEMICOLON)) {
      return _parseEmptyStatement();
    } else if (_isInitializedVariableDeclaration()) {
      return _parseVariableDeclarationStatementAfterMetadata(
          commentAndMetadata);
    } else if (_isFunctionDeclaration()) {
      return _parseFunctionDeclarationStatement();
    } else if (_matches(TokenType.CLOSE_CURLY_BRACKET)) {
      _reportErrorForCurrentToken(ParserErrorCode.MISSING_STATEMENT);
      return new EmptyStatement(_createSyntheticToken(TokenType.SEMICOLON));
    } else {
      return new ExpressionStatement(parseExpression2(), _expectSemicolon());
    }
  }

  /**
   * Parse an operator declaration. The [commentAndMetadata] is the
   * documentation comment and metadata to be associated with the declaration.
   * The [externalKeyword] is the 'external' token. The [returnType] is the
   * return type that has already been parsed, or `null` if there was no return
   * type. Return the operator declaration that was parsed.
   *
   *     operatorDeclaration ::=
   *         operatorSignature (';' | functionBody)
   *
   *     operatorSignature ::=
   *         'external'? returnType? 'operator' operator formalParameterList
   */
  MethodDeclaration _parseOperator(CommentAndMetadata commentAndMetadata,
      Token externalKeyword, TypeName returnType) {
    Token operatorKeyword;
    if (_matchesKeyword(Keyword.OPERATOR)) {
      operatorKeyword = getAndAdvance();
    } else {
      _reportErrorForToken(
          ParserErrorCode.MISSING_KEYWORD_OPERATOR, _currentToken);
      operatorKeyword = _createSyntheticKeyword(Keyword.OPERATOR);
    }
    if (!_currentToken.isUserDefinableOperator) {
      _reportErrorForCurrentToken(
          ParserErrorCode.NON_USER_DEFINABLE_OPERATOR, [_currentToken.lexeme]);
    }
    SimpleIdentifier name = new SimpleIdentifier(getAndAdvance());
    if (_matches(TokenType.EQ)) {
      Token previous = _currentToken.previous;
      if ((_tokenMatches(previous, TokenType.EQ_EQ) ||
              _tokenMatches(previous, TokenType.BANG_EQ)) &&
          _currentToken.offset == previous.offset + 2) {
        _reportErrorForCurrentToken(ParserErrorCode.INVALID_OPERATOR,
            ["${previous.lexeme}${_currentToken.lexeme}"]);
        _advance();
      }
    }
    FormalParameterList parameters = parseFormalParameterList();
    _validateFormalParameterList(parameters);
    FunctionBody body =
        _parseFunctionBody(true, ParserErrorCode.MISSING_FUNCTION_BODY, false);
    if (externalKeyword != null && body is! EmptyFunctionBody) {
      _reportErrorForCurrentToken(ParserErrorCode.EXTERNAL_OPERATOR_WITH_BODY);
    }
    return new MethodDeclaration(commentAndMetadata.comment,
        commentAndMetadata.metadata, externalKeyword, null, returnType, null,
        operatorKeyword, name, null, parameters, body);
  }

  /**
   * Parse a return type if one is given, otherwise return `null` without
   * advancing. Return the return type that was parsed.
   */
  TypeName _parseOptionalReturnType() {
    if (_matchesKeyword(Keyword.VOID)) {
      return parseReturnType();
    } else if (_matchesIdentifier() &&
        !_matchesKeyword(Keyword.GET) &&
        !_matchesKeyword(Keyword.SET) &&
        !_matchesKeyword(Keyword.OPERATOR) &&
        (_tokenMatchesIdentifier(_peek()) ||
            _tokenMatches(_peek(), TokenType.LT))) {
      return parseReturnType();
    } else if (_matchesIdentifier() &&
        _tokenMatches(_peek(), TokenType.PERIOD) &&
        _tokenMatchesIdentifier(_peekAt(2)) &&
        (_tokenMatchesIdentifier(_peekAt(3)) ||
            _tokenMatches(_peekAt(3), TokenType.LT))) {
      return parseReturnType();
    }
    return null;
  }

  /**
   * Parse a part or part-of directive. The [commentAndMetadata] is the metadata
   * to be associated with the directive. Return the part or part-of directive
   * that was parsed.
   *
   *     partDirective ::=
   *         metadata 'part' stringLiteral ';'
   *
   *     partOfDirective ::=
   *         metadata 'part' 'of' identifier ';'
   */
  Directive _parsePartDirective(CommentAndMetadata commentAndMetadata) {
    Token partKeyword = _expectKeyword(Keyword.PART);
    if (_matchesString(_OF)) {
      Token ofKeyword = getAndAdvance();
      LibraryIdentifier libraryName = _parseLibraryName(
          ParserErrorCode.MISSING_NAME_IN_PART_OF_DIRECTIVE, ofKeyword);
      Token semicolon = _expect(TokenType.SEMICOLON);
      return new PartOfDirective(commentAndMetadata.comment,
          commentAndMetadata.metadata, partKeyword, ofKeyword, libraryName,
          semicolon);
    }
    StringLiteral partUri = _parseUri();
    Token semicolon = _expect(TokenType.SEMICOLON);
    return new PartDirective(commentAndMetadata.comment,
        commentAndMetadata.metadata, partKeyword, partUri, semicolon);
  }

  /**
   * Parse a postfix expression. Return the postfix expression that was parsed.
   *
   *     postfixExpression ::=
   *         assignableExpression postfixOperator
   *       | primary selector*
   *
   *     selector ::=
   *         assignableSelector
   *       | argumentList
   */
  Expression _parsePostfixExpression() {
    Expression operand = _parseAssignableExpression(true);
    if (_matches(TokenType.OPEN_SQUARE_BRACKET) ||
        _matches(TokenType.PERIOD) ||
        _matches(TokenType.QUESTION_PERIOD) ||
        _matches(TokenType.OPEN_PAREN) ||
        (parseGenericMethods && _matches(TokenType.LT))) {
      do {
        if (_isLikelyParameterList()) {
          TypeArgumentList typeArguments = null;
          if (_matches(TokenType.LT)) {
            typeArguments = parseTypeArgumentList();
          }
          ArgumentList argumentList = parseArgumentList();
          if (operand is PropertyAccess) {
            PropertyAccess access = operand as PropertyAccess;
            operand = new MethodInvocation(access.target, access.operator,
                access.propertyName, typeArguments, argumentList);
          } else {
            operand = new FunctionExpressionInvocation(
                operand, typeArguments, argumentList);
          }
        } else {
          operand = _parseAssignableSelector(operand, true);
        }
      } while (_matches(TokenType.OPEN_SQUARE_BRACKET) ||
          _matches(TokenType.PERIOD) ||
          _matches(TokenType.QUESTION_PERIOD) ||
          _matches(TokenType.OPEN_PAREN));
      return operand;
    }
    if (!_currentToken.type.isIncrementOperator) {
      return operand;
    }
    _ensureAssignable(operand);
    Token operator = getAndAdvance();
    return new PostfixExpression(operand, operator);
  }

  /**
   * Parse a primary expression. Return the primary expression that was parsed.
   *
   *     primary ::=
   *         thisExpression
   *       | 'super' unconditionalAssignableSelector
   *       | functionExpression
   *       | literal
   *       | identifier
   *       | newExpression
   *       | constObjectExpression
   *       | '(' expression ')'
   *       | argumentDefinitionTest
   *
   *     literal ::=
   *         nullLiteral
   *       | booleanLiteral
   *       | numericLiteral
   *       | stringLiteral
   *       | symbolLiteral
   *       | mapLiteral
   *       | listLiteral
   */
  Expression _parsePrimaryExpression() {
    if (_matchesKeyword(Keyword.THIS)) {
      return new ThisExpression(getAndAdvance());
    } else if (_matchesKeyword(Keyword.SUPER)) {
      // TODO(paulberry): verify with Gilad that "super" must be followed by
      // unconditionalAssignableSelector in this case.
      return _parseAssignableSelector(
          new SuperExpression(getAndAdvance()), false, allowConditional: false);
    } else if (_matchesKeyword(Keyword.NULL)) {
      return new NullLiteral(getAndAdvance());
    } else if (_matchesKeyword(Keyword.FALSE)) {
      return new BooleanLiteral(getAndAdvance(), false);
    } else if (_matchesKeyword(Keyword.TRUE)) {
      return new BooleanLiteral(getAndAdvance(), true);
    } else if (_matches(TokenType.DOUBLE)) {
      Token token = getAndAdvance();
      double value = 0.0;
      try {
        value = double.parse(token.lexeme);
      } on FormatException {
        // The invalid format should have been reported by the scanner.
      }
      return new DoubleLiteral(token, value);
    } else if (_matches(TokenType.HEXADECIMAL)) {
      Token token = getAndAdvance();
      int value = null;
      try {
        value = int.parse(token.lexeme.substring(2), radix: 16);
      } on FormatException {
        // The invalid format should have been reported by the scanner.
      }
      return new IntegerLiteral(token, value);
    } else if (_matches(TokenType.INT)) {
      Token token = getAndAdvance();
      int value = null;
      try {
        value = int.parse(token.lexeme);
      } on FormatException {
        // The invalid format should have been reported by the scanner.
      }
      return new IntegerLiteral(token, value);
    } else if (_matches(TokenType.STRING)) {
      return parseStringLiteral();
    } else if (_matches(TokenType.OPEN_CURLY_BRACKET)) {
      return _parseMapLiteral(null, null);
    } else if (_matches(TokenType.OPEN_SQUARE_BRACKET) ||
        _matches(TokenType.INDEX)) {
      return _parseListLiteral(null, null);
    } else if (_matchesIdentifier()) {
      // TODO(brianwilkerson) The code below was an attempt to recover from an
      // error case, but it needs to be applied as a recovery only after we
      // know that parsing it as an identifier doesn't work. Leaving the code as
      // a reminder of how to recover.
//            if (isFunctionExpression(peek())) {
//              //
//              // Function expressions were allowed to have names at one point, but this is now illegal.
//              //
//              reportError(ParserErrorCode.NAMED_FUNCTION_EXPRESSION, getAndAdvance());
//              return parseFunctionExpression();
//            }
      return parsePrefixedIdentifier();
    } else if (_matchesKeyword(Keyword.NEW)) {
      return _parseNewExpression();
    } else if (_matchesKeyword(Keyword.CONST)) {
      return _parseConstExpression();
    } else if (_matches(TokenType.OPEN_PAREN)) {
      if (_isFunctionExpression(_currentToken)) {
        return parseFunctionExpression();
      }
      Token leftParenthesis = getAndAdvance();
      bool wasInInitializer = _inInitializer;
      _inInitializer = false;
      try {
        Expression expression = parseExpression2();
        Token rightParenthesis = _expect(TokenType.CLOSE_PAREN);
        return new ParenthesizedExpression(
            leftParenthesis, expression, rightParenthesis);
      } finally {
        _inInitializer = wasInInitializer;
      }
    } else if (_matches(TokenType.LT)) {
      return _parseListOrMapLiteral(null);
    } else if (_matches(TokenType.QUESTION) &&
        _tokenMatches(_peek(), TokenType.IDENTIFIER)) {
      _reportErrorForCurrentToken(
          ParserErrorCode.UNEXPECTED_TOKEN, [_currentToken.lexeme]);
      _advance();
      return _parsePrimaryExpression();
    } else if (_matchesKeyword(Keyword.VOID)) {
      //
      // Recover from having a return type of "void" where a return type is not
      // expected.
      //
      // TODO(brianwilkerson) Improve this error message.
      _reportErrorForCurrentToken(
          ParserErrorCode.UNEXPECTED_TOKEN, [_currentToken.lexeme]);
      _advance();
      return _parsePrimaryExpression();
    } else if (_matches(TokenType.HASH)) {
      return _parseSymbolLiteral();
    } else {
      _reportErrorForCurrentToken(ParserErrorCode.MISSING_IDENTIFIER);
      return _createSyntheticIdentifier();
    }
  }

  /**
   * Parse a redirecting constructor invocation. Return the redirecting
   * constructor invocation that was parsed.
   *
   *     redirectingConstructorInvocation ::=
   *         'this' ('.' identifier)? arguments
   */
  RedirectingConstructorInvocation _parseRedirectingConstructorInvocation() {
    Token keyword = _expectKeyword(Keyword.THIS);
    Token period = null;
    SimpleIdentifier constructorName = null;
    if (_matches(TokenType.PERIOD)) {
      period = getAndAdvance();
      constructorName = parseSimpleIdentifier();
    }
    ArgumentList argumentList = parseArgumentList();
    return new RedirectingConstructorInvocation(
        keyword, period, constructorName, argumentList);
  }

  /**
   * Parse a relational expression. Return the relational expression that was
   * parsed.
   *
   *     relationalExpression ::=
   *         bitwiseOrExpression ('is' '!'? type | 'as' type | relationalOperator bitwiseOrExpression)?
   *       | 'super' relationalOperator bitwiseOrExpression
   */
  Expression _parseRelationalExpression() {
    if (_matchesKeyword(Keyword.SUPER) &&
        _currentToken.next.type.isRelationalOperator) {
      Expression expression = new SuperExpression(getAndAdvance());
      Token operator = getAndAdvance();
      expression = new BinaryExpression(
          expression, operator, parseBitwiseOrExpression());
      return expression;
    }
    Expression expression = parseBitwiseOrExpression();
    if (_matchesKeyword(Keyword.AS)) {
      Token asOperator = getAndAdvance();
      expression = new AsExpression(expression, asOperator, parseTypeName());
    } else if (_matchesKeyword(Keyword.IS)) {
      Token isOperator = getAndAdvance();
      Token notOperator = null;
      if (_matches(TokenType.BANG)) {
        notOperator = getAndAdvance();
      }
      expression = new IsExpression(
          expression, isOperator, notOperator, parseTypeName());
    } else if (_currentToken.type.isRelationalOperator) {
      Token operator = getAndAdvance();
      expression = new BinaryExpression(
          expression, operator, parseBitwiseOrExpression());
    }
    return expression;
  }

  /**
   * Parse a rethrow expression. Return the rethrow expression that was parsed.
   *
   *     rethrowExpression ::=
   *         'rethrow'
   */
  Expression _parseRethrowExpression() =>
      new RethrowExpression(_expectKeyword(Keyword.RETHROW));

  /**
   * Parse a return statement. Return the return statement that was parsed.
   *
   *     returnStatement ::=
   *         'return' expression? ';'
   */
  Statement _parseReturnStatement() {
    Token returnKeyword = _expectKeyword(Keyword.RETURN);
    if (_matches(TokenType.SEMICOLON)) {
      return new ReturnStatement(returnKeyword, null, getAndAdvance());
    }
    Expression expression = parseExpression2();
    Token semicolon = _expect(TokenType.SEMICOLON);
    return new ReturnStatement(returnKeyword, expression, semicolon);
  }

  /**
   * Parse a setter. The [commentAndMetadata] is the documentation comment and
   * metadata to be associated with the declaration. The [externalKeyword] is
   * the 'external' token. The [staticKeyword] is the static keyword, or `null`
   * if the setter is not static. The [returnType] is the return type that has
   * already been parsed, or `null` if there was no return type. Return the
   * setter that was parsed.
   *
   *     setter ::=
   *         setterSignature functionBody?
   *
   *     setterSignature ::=
   *         'external'? 'static'? returnType? 'set' identifier formalParameterList
   */
  MethodDeclaration _parseSetter(CommentAndMetadata commentAndMetadata,
      Token externalKeyword, Token staticKeyword, TypeName returnType) {
    Token propertyKeyword = _expectKeyword(Keyword.SET);
    SimpleIdentifier name = parseSimpleIdentifier();
    FormalParameterList parameters = parseFormalParameterList();
    _validateFormalParameterList(parameters);
    FunctionBody body = _parseFunctionBody(
        externalKeyword != null || staticKeyword == null,
        ParserErrorCode.STATIC_SETTER_WITHOUT_BODY, false);
    if (externalKeyword != null && body is! EmptyFunctionBody) {
      _reportErrorForCurrentToken(ParserErrorCode.EXTERNAL_SETTER_WITH_BODY);
    }
    return new MethodDeclaration(commentAndMetadata.comment,
        commentAndMetadata.metadata, externalKeyword, staticKeyword, returnType,
        propertyKeyword, null, name, null, parameters, body);
  }

  /**
   * Parse a shift expression. Return the shift expression that was parsed.
   *
   *     shiftExpression ::=
   *         additiveExpression (shiftOperator additiveExpression)*
   *       | 'super' (shiftOperator additiveExpression)+
   */
  Expression _parseShiftExpression() {
    Expression expression;
    if (_matchesKeyword(Keyword.SUPER) &&
        _currentToken.next.type.isShiftOperator) {
      expression = new SuperExpression(getAndAdvance());
    } else {
      expression = _parseAdditiveExpression();
    }
    while (_currentToken.type.isShiftOperator) {
      Token operator = getAndAdvance();
      expression = new BinaryExpression(
          expression, operator, _parseAdditiveExpression());
    }
    return expression;
  }

  /**
   * Parse a list of statements within a switch statement. Return the statements
   * that were parsed.
   *
   *     statements ::=
   *         statement*
   */
  List<Statement> _parseStatementList() {
    List<Statement> statements = new List<Statement>();
    Token statementStart = _currentToken;
    while (!_matches(TokenType.EOF) &&
        !_matches(TokenType.CLOSE_CURLY_BRACKET) &&
        !_isSwitchMember()) {
      statements.add(parseStatement2());
      if (identical(_currentToken, statementStart)) {
        _reportErrorForToken(ParserErrorCode.UNEXPECTED_TOKEN, _currentToken,
            [_currentToken.lexeme]);
        _advance();
      }
      statementStart = _currentToken;
    }
    return statements;
  }

  /**
   * Parse a string literal that contains interpolations. Return the string
   * literal that was parsed.
   */
  StringInterpolation _parseStringInterpolation(Token string) {
    List<InterpolationElement> elements = new List<InterpolationElement>();
    bool hasMore = _matches(TokenType.STRING_INTERPOLATION_EXPRESSION) ||
        _matches(TokenType.STRING_INTERPOLATION_IDENTIFIER);
    elements.add(new InterpolationString(
        string, _computeStringValue(string.lexeme, true, !hasMore)));
    while (hasMore) {
      if (_matches(TokenType.STRING_INTERPOLATION_EXPRESSION)) {
        Token openToken = getAndAdvance();
        bool wasInInitializer = _inInitializer;
        _inInitializer = false;
        try {
          Expression expression = parseExpression2();
          Token rightBracket = _expect(TokenType.CLOSE_CURLY_BRACKET);
          elements.add(
              new InterpolationExpression(openToken, expression, rightBracket));
        } finally {
          _inInitializer = wasInInitializer;
        }
      } else {
        Token openToken = getAndAdvance();
        Expression expression = null;
        if (_matchesKeyword(Keyword.THIS)) {
          expression = new ThisExpression(getAndAdvance());
        } else {
          expression = parseSimpleIdentifier();
        }
        elements.add(new InterpolationExpression(openToken, expression, null));
      }
      if (_matches(TokenType.STRING)) {
        string = getAndAdvance();
        hasMore = _matches(TokenType.STRING_INTERPOLATION_EXPRESSION) ||
            _matches(TokenType.STRING_INTERPOLATION_IDENTIFIER);
        elements.add(new InterpolationString(
            string, _computeStringValue(string.lexeme, false, !hasMore)));
      } else {
        hasMore = false;
      }
    }
    return new StringInterpolation(elements);
  }

  /**
   * Parse a super constructor invocation. Return the super constructor
   * invocation that was parsed.
   *
   *     superConstructorInvocation ::=
   *         'super' ('.' identifier)? arguments
   */
  SuperConstructorInvocation _parseSuperConstructorInvocation() {
    Token keyword = _expectKeyword(Keyword.SUPER);
    Token period = null;
    SimpleIdentifier constructorName = null;
    if (_matches(TokenType.PERIOD)) {
      period = getAndAdvance();
      constructorName = parseSimpleIdentifier();
    }
    ArgumentList argumentList = parseArgumentList();
    return new SuperConstructorInvocation(
        keyword, period, constructorName, argumentList);
  }

  /**
   * Parse a switch statement. Return the switch statement that was parsed.
   *
   *     switchStatement ::=
   *         'switch' '(' expression ')' '{' switchCase* defaultCase? '}'
   *
   *     switchCase ::=
   *         label* ('case' expression ':') statements
   *
   *     defaultCase ::=
   *         label* 'default' ':' statements
   */
  SwitchStatement _parseSwitchStatement() {
    bool wasInSwitch = _inSwitch;
    _inSwitch = true;
    try {
      HashSet<String> definedLabels = new HashSet<String>();
      Token keyword = _expectKeyword(Keyword.SWITCH);
      Token leftParenthesis = _expect(TokenType.OPEN_PAREN);
      Expression expression = parseExpression2();
      Token rightParenthesis = _expect(TokenType.CLOSE_PAREN);
      Token leftBracket = _expect(TokenType.OPEN_CURLY_BRACKET);
      Token defaultKeyword = null;
      List<SwitchMember> members = new List<SwitchMember>();
      while (!_matches(TokenType.EOF) &&
          !_matches(TokenType.CLOSE_CURLY_BRACKET)) {
        List<Label> labels = new List<Label>();
        while (
            _matchesIdentifier() && _tokenMatches(_peek(), TokenType.COLON)) {
          SimpleIdentifier identifier = parseSimpleIdentifier();
          String label = identifier.token.lexeme;
          if (definedLabels.contains(label)) {
            _reportErrorForToken(
                ParserErrorCode.DUPLICATE_LABEL_IN_SWITCH_STATEMENT,
                identifier.token, [label]);
          } else {
            definedLabels.add(label);
          }
          Token colon = _expect(TokenType.COLON);
          labels.add(new Label(identifier, colon));
        }
        if (_matchesKeyword(Keyword.CASE)) {
          Token caseKeyword = getAndAdvance();
          Expression caseExpression = parseExpression2();
          Token colon = _expect(TokenType.COLON);
          members.add(new SwitchCase(labels, caseKeyword, caseExpression, colon,
              _parseStatementList()));
          if (defaultKeyword != null) {
            _reportErrorForToken(
                ParserErrorCode.SWITCH_HAS_CASE_AFTER_DEFAULT_CASE,
                caseKeyword);
          }
        } else if (_matchesKeyword(Keyword.DEFAULT)) {
          if (defaultKeyword != null) {
            _reportErrorForToken(
                ParserErrorCode.SWITCH_HAS_MULTIPLE_DEFAULT_CASES, _peek());
          }
          defaultKeyword = getAndAdvance();
          Token colon = _expect(TokenType.COLON);
          members.add(new SwitchDefault(
              labels, defaultKeyword, colon, _parseStatementList()));
        } else {
          // We need to advance, otherwise we could end up in an infinite loop,
          // but this could be a lot smarter about recovering from the error.
          _reportErrorForCurrentToken(ParserErrorCode.EXPECTED_CASE_OR_DEFAULT);
          while (!_matches(TokenType.EOF) &&
              !_matches(TokenType.CLOSE_CURLY_BRACKET) &&
              !_matchesKeyword(Keyword.CASE) &&
              !_matchesKeyword(Keyword.DEFAULT)) {
            _advance();
          }
        }
      }
      Token rightBracket = _expect(TokenType.CLOSE_CURLY_BRACKET);
      return new SwitchStatement(keyword, leftParenthesis, expression,
          rightParenthesis, leftBracket, members, rightBracket);
    } finally {
      _inSwitch = wasInSwitch;
    }
  }

  /**
   * Parse a symbol literal. Return the symbol literal that was parsed.
   *
   *     symbolLiteral ::=
   *         '#' identifier ('.' identifier)*
   */
  SymbolLiteral _parseSymbolLiteral() {
    Token poundSign = getAndAdvance();
    List<Token> components = new List<Token>();
    if (_matchesIdentifier()) {
      components.add(getAndAdvance());
      while (_matches(TokenType.PERIOD)) {
        _advance();
        if (_matchesIdentifier()) {
          components.add(getAndAdvance());
        } else {
          _reportErrorForCurrentToken(ParserErrorCode.MISSING_IDENTIFIER);
          components.add(_createSyntheticToken(TokenType.IDENTIFIER));
          break;
        }
      }
    } else if (_currentToken.isOperator) {
      components.add(getAndAdvance());
    } else if (_tokenMatchesKeyword(_currentToken, Keyword.VOID)) {
      components.add(getAndAdvance());
    } else {
      _reportErrorForCurrentToken(ParserErrorCode.MISSING_IDENTIFIER);
      components.add(_createSyntheticToken(TokenType.IDENTIFIER));
    }
    return new SymbolLiteral(poundSign, components);
  }

  /**
   * Parse a throw expression. Return the throw expression that was parsed.
   *
   *     throwExpression ::=
   *         'throw' expression
   */
  Expression _parseThrowExpression() {
    Token keyword = _expectKeyword(Keyword.THROW);
    if (_matches(TokenType.SEMICOLON) || _matches(TokenType.CLOSE_PAREN)) {
      _reportErrorForToken(
          ParserErrorCode.MISSING_EXPRESSION_IN_THROW, _currentToken);
      return new ThrowExpression(keyword, _createSyntheticIdentifier());
    }
    Expression expression = parseExpression2();
    return new ThrowExpression(keyword, expression);
  }

  /**
   * Parse a throw expression. Return the throw expression that was parsed.
   *
   *     throwExpressionWithoutCascade ::=
   *         'throw' expressionWithoutCascade
   */
  Expression _parseThrowExpressionWithoutCascade() {
    Token keyword = _expectKeyword(Keyword.THROW);
    if (_matches(TokenType.SEMICOLON) || _matches(TokenType.CLOSE_PAREN)) {
      _reportErrorForToken(
          ParserErrorCode.MISSING_EXPRESSION_IN_THROW, _currentToken);
      return new ThrowExpression(keyword, _createSyntheticIdentifier());
    }
    Expression expression = parseExpressionWithoutCascade();
    return new ThrowExpression(keyword, expression);
  }

  /**
   * Parse a try statement. Return the try statement that was parsed.
   *
   *     tryStatement ::=
   *         'try' block (onPart+ finallyPart? | finallyPart)
   *
   *     onPart ::=
   *         catchPart block
   *       | 'on' type catchPart? block
   *
   *     catchPart ::=
   *         'catch' '(' identifier (',' identifier)? ')'
   *
   *     finallyPart ::=
   *         'finally' block
   */
  Statement _parseTryStatement() {
    Token tryKeyword = _expectKeyword(Keyword.TRY);
    Block body = parseBlock();
    List<CatchClause> catchClauses = new List<CatchClause>();
    Block finallyClause = null;
    while (_matchesString(_ON) || _matchesKeyword(Keyword.CATCH)) {
      Token onKeyword = null;
      TypeName exceptionType = null;
      if (_matchesString(_ON)) {
        onKeyword = getAndAdvance();
        exceptionType = parseTypeName();
      }
      Token catchKeyword = null;
      Token leftParenthesis = null;
      SimpleIdentifier exceptionParameter = null;
      Token comma = null;
      SimpleIdentifier stackTraceParameter = null;
      Token rightParenthesis = null;
      if (_matchesKeyword(Keyword.CATCH)) {
        catchKeyword = getAndAdvance();
        leftParenthesis = _expect(TokenType.OPEN_PAREN);
        exceptionParameter = parseSimpleIdentifier();
        if (_matches(TokenType.COMMA)) {
          comma = getAndAdvance();
          stackTraceParameter = parseSimpleIdentifier();
        }
        rightParenthesis = _expect(TokenType.CLOSE_PAREN);
      }
      Block catchBody = parseBlock();
      catchClauses.add(new CatchClause(onKeyword, exceptionType, catchKeyword,
          leftParenthesis, exceptionParameter, comma, stackTraceParameter,
          rightParenthesis, catchBody));
    }
    Token finallyKeyword = null;
    if (_matchesKeyword(Keyword.FINALLY)) {
      finallyKeyword = getAndAdvance();
      finallyClause = parseBlock();
    } else {
      if (catchClauses.isEmpty) {
        _reportErrorForCurrentToken(ParserErrorCode.MISSING_CATCH_OR_FINALLY);
      }
    }
    return new TryStatement(
        tryKeyword, body, catchClauses, finallyKeyword, finallyClause);
  }

  /**
   * Parse a type alias. The [commentAndMetadata] is the metadata to be
   * associated with the member. Return the type alias that was parsed.
   *
   *     typeAlias ::=
   *         'typedef' typeAliasBody
   *
   *     typeAliasBody ::=
   *         classTypeAlias
   *       | functionTypeAlias
   *
   *     classTypeAlias ::=
   *         identifier typeParameters? '=' 'abstract'? mixinApplication
   *
   *     mixinApplication ::=
   *         qualified withClause implementsClause? ';'
   *
   *     functionTypeAlias ::=
   *         functionPrefix typeParameterList? formalParameterList ';'
   *
   *     functionPrefix ::=
   *         returnType? name
   */
  TypeAlias _parseTypeAlias(CommentAndMetadata commentAndMetadata) {
    Token keyword = _expectKeyword(Keyword.TYPEDEF);
    if (_matchesIdentifier()) {
      Token next = _peek();
      if (_tokenMatches(next, TokenType.LT)) {
        next = _skipTypeParameterList(next);
        if (next != null && _tokenMatches(next, TokenType.EQ)) {
          TypeAlias typeAlias =
              _parseClassTypeAlias(commentAndMetadata, null, keyword);
          _reportErrorForToken(
              ParserErrorCode.DEPRECATED_CLASS_TYPE_ALIAS, keyword);
          return typeAlias;
        }
      } else if (_tokenMatches(next, TokenType.EQ)) {
        TypeAlias typeAlias =
            _parseClassTypeAlias(commentAndMetadata, null, keyword);
        _reportErrorForToken(
            ParserErrorCode.DEPRECATED_CLASS_TYPE_ALIAS, keyword);
        return typeAlias;
      }
    }
    return _parseFunctionTypeAlias(commentAndMetadata, keyword);
  }

  /**
   * Parse a unary expression. Return the unary expression that was parsed.
   *
   *     unaryExpression ::=
   *         prefixOperator unaryExpression
   *       | awaitExpression
   *       | postfixExpression
   *       | unaryOperator 'super'
   *       | '-' 'super'
   *       | incrementOperator assignableExpression
   */
  Expression _parseUnaryExpression() {
    if (_matches(TokenType.MINUS) ||
        _matches(TokenType.BANG) ||
        _matches(TokenType.TILDE)) {
      Token operator = getAndAdvance();
      if (_matchesKeyword(Keyword.SUPER)) {
        if (_tokenMatches(_peek(), TokenType.OPEN_SQUARE_BRACKET) ||
            _tokenMatches(_peek(), TokenType.PERIOD)) {
          //     "prefixOperator unaryExpression"
          // --> "prefixOperator postfixExpression"
          // --> "prefixOperator primary                    selector*"
          // --> "prefixOperator 'super' assignableSelector selector*"
          return new PrefixExpression(operator, _parseUnaryExpression());
        }
        return new PrefixExpression(
            operator, new SuperExpression(getAndAdvance()));
      }
      return new PrefixExpression(operator, _parseUnaryExpression());
    } else if (_currentToken.type.isIncrementOperator) {
      Token operator = getAndAdvance();
      if (_matchesKeyword(Keyword.SUPER)) {
        if (_tokenMatches(_peek(), TokenType.OPEN_SQUARE_BRACKET) ||
            _tokenMatches(_peek(), TokenType.PERIOD)) {
          // --> "prefixOperator 'super' assignableSelector selector*"
          return new PrefixExpression(operator, _parseUnaryExpression());
        }
        //
        // Even though it is not valid to use an incrementing operator
        // ('++' or '--') before 'super', we can (and therefore must) interpret
        // "--super" as semantically equivalent to "-(-super)". Unfortunately,
        // we cannot do the same for "++super" because "+super" is also not
        // valid.
        //
        if (operator.type == TokenType.MINUS_MINUS) {
          Token firstOperator = _createToken(operator, TokenType.MINUS);
          Token secondOperator =
              new Token(TokenType.MINUS, operator.offset + 1);
          secondOperator.setNext(_currentToken);
          firstOperator.setNext(secondOperator);
          operator.previous.setNext(firstOperator);
          return new PrefixExpression(firstOperator, new PrefixExpression(
              secondOperator, new SuperExpression(getAndAdvance())));
        } else {
          // Invalid operator before 'super'
          _reportErrorForCurrentToken(
              ParserErrorCode.INVALID_OPERATOR_FOR_SUPER, [operator.lexeme]);
          return new PrefixExpression(
              operator, new SuperExpression(getAndAdvance()));
        }
      }
      return new PrefixExpression(operator, _parseAssignableExpression(false));
    } else if (_matches(TokenType.PLUS)) {
      _reportErrorForCurrentToken(ParserErrorCode.MISSING_IDENTIFIER);
      return _createSyntheticIdentifier();
    } else if (_inAsync && _matchesString(_AWAIT)) {
      return _parseAwaitExpression();
    }
    return _parsePostfixExpression();
  }

  /**
   * Parse a string literal representing a URI. Return the string literal that
   * was parsed.
   */
  StringLiteral _parseUri() {
    bool iskeywordAfterUri(Token token) => token.lexeme == Keyword.AS.syntax ||
        token.lexeme == _HIDE ||
        token.lexeme == _SHOW;
    if (!_matches(TokenType.STRING) &&
        !_matches(TokenType.SEMICOLON) &&
        !iskeywordAfterUri(_currentToken)) {
      // Attempt to recover in the case where the URI was not enclosed in
      // quotes.
      Token token = _currentToken;
      while ((_tokenMatchesIdentifier(token) && !iskeywordAfterUri(token)) ||
          _tokenMatches(token, TokenType.COLON) ||
          _tokenMatches(token, TokenType.SLASH) ||
          _tokenMatches(token, TokenType.PERIOD) ||
          _tokenMatches(token, TokenType.PERIOD_PERIOD) ||
          _tokenMatches(token, TokenType.PERIOD_PERIOD_PERIOD) ||
          _tokenMatches(token, TokenType.INT) ||
          _tokenMatches(token, TokenType.DOUBLE)) {
        token = token.next;
      }
      if (_tokenMatches(token, TokenType.SEMICOLON) ||
          iskeywordAfterUri(token)) {
        Token endToken = token.previous;
        token = _currentToken;
        int endOffset = token.end;
        StringBuffer buffer = new StringBuffer();
        buffer.write(token.lexeme);
        while (token != endToken) {
          token = token.next;
          if (token.offset != endOffset || token.precedingComments != null) {
            return parseStringLiteral();
          }
          buffer.write(token.lexeme);
          endOffset = token.end;
        }
        String value = buffer.toString();
        Token newToken =
            new StringToken(TokenType.STRING, "'$value'", _currentToken.offset);
        _reportErrorForToken(
            ParserErrorCode.NON_STRING_LITERAL_AS_URI, newToken);
        _currentToken = endToken.next;
        return new SimpleStringLiteral(newToken, value);
      }
    }
    return parseStringLiteral();
  }

  /**
   * Parse a variable declaration. Return the variable declaration that was
   * parsed.
   *
   *     variableDeclaration ::=
   *         identifier ('=' expression)?
   */
  VariableDeclaration _parseVariableDeclaration() {
    // TODO(paulberry): prior to the fix for bug 23204, we permitted
    // annotations before variable declarations (e.g. "String @deprecated s;").
    // Although such constructions are prohibited by the spec, we may want to
    // consider handling them anyway to allow for better parser recovery in the
    // event that the user erroneously tries to use them.  However, as a
    // counterargument, this would likely degrade parser recovery in the event
    // of a construct like "class C { int @deprecated foo() {} }" (i.e. the
    // user is in the middle of inserting "int bar;" prior to
    // "@deprecated foo() {}").
    SimpleIdentifier name = parseSimpleIdentifier();
    Token equals = null;
    Expression initializer = null;
    if (_matches(TokenType.EQ)) {
      equals = getAndAdvance();
      initializer = parseExpression2();
    }
    return new VariableDeclaration(name, equals, initializer);
  }

  /**
   * Parse a variable declaration list. The [commentAndMetadata] is the metadata
   * to be associated with the variable declaration list. Return the variable
   * declaration list that was parsed.
   *
   *     variableDeclarationList ::=
   *         finalConstVarOrType variableDeclaration (',' variableDeclaration)*
   */
  VariableDeclarationList _parseVariableDeclarationListAfterMetadata(
      CommentAndMetadata commentAndMetadata) {
    FinalConstVarOrType holder = _parseFinalConstVarOrType(false);
    return _parseVariableDeclarationListAfterType(
        commentAndMetadata, holder.keyword, holder.type);
  }

  /**
   * Parse a variable declaration list. The [commentAndMetadata] is the metadata
   * to be associated with the variable declaration list, or `null` if there is
   * no attempt at parsing the comment and metadata. The [keyword] is the token
   * representing the 'final', 'const' or 'var' keyword, or `null` if there is
   * no keyword. The [type] is the type of the variables in the list. Return the
   * variable declaration list that was parsed.
   *
   *     variableDeclarationList ::=
   *         finalConstVarOrType variableDeclaration (',' variableDeclaration)*
   */
  VariableDeclarationList _parseVariableDeclarationListAfterType(
      CommentAndMetadata commentAndMetadata, Token keyword, TypeName type) {
    if (type != null &&
        keyword != null &&
        _tokenMatchesKeyword(keyword, Keyword.VAR)) {
      _reportErrorForToken(ParserErrorCode.VAR_AND_TYPE, keyword);
    }
    List<VariableDeclaration> variables = new List<VariableDeclaration>();
    variables.add(_parseVariableDeclaration());
    while (_matches(TokenType.COMMA)) {
      _advance();
      variables.add(_parseVariableDeclaration());
    }
    return new VariableDeclarationList(
        commentAndMetadata != null ? commentAndMetadata.comment : null,
        commentAndMetadata != null ? commentAndMetadata.metadata : null,
        keyword, type, variables);
  }

  /**
   * Parse a variable declaration statement. The [commentAndMetadata] is the
   * metadata to be associated with the variable declaration statement, or
   * `null` if there is no attempt at parsing the comment and metadata. Return
   * the variable declaration statement that was parsed.
   *
   *     variableDeclarationStatement ::=
   *         variableDeclarationList ';'
   */
  VariableDeclarationStatement _parseVariableDeclarationStatementAfterMetadata(
      CommentAndMetadata commentAndMetadata) {
    //    Token startToken = currentToken;
    VariableDeclarationList variableList =
        _parseVariableDeclarationListAfterMetadata(commentAndMetadata);
//        if (!matches(TokenType.SEMICOLON)) {
//          if (matches(startToken, Keyword.VAR) && isTypedIdentifier(startToken.getNext())) {
//            // TODO(brianwilkerson) This appears to be of the form "var type variable". We should do
//            // a better job of recovering in this case.
//          }
//        }
    Token semicolon = _expect(TokenType.SEMICOLON);
    return new VariableDeclarationStatement(variableList, semicolon);
  }

  /**
   * Parse a variable declaration statement. The [commentAndMetadata] is the
   * metadata to be associated with the variable declaration statement, or
   * `null` if there is no attempt at parsing the comment and metadata. The
   * [keyword] is the token representing the 'final', 'const' or 'var' keyword,
   * or `null` if there is no keyword. The [type] is the type of the variables
   * in the list. Return the variable declaration statement that was parsed.
   *
   *     variableDeclarationStatement ::=
   *         variableDeclarationList ';'
   */
  VariableDeclarationStatement _parseVariableDeclarationStatementAfterType(
      CommentAndMetadata commentAndMetadata, Token keyword, TypeName type) {
    VariableDeclarationList variableList =
        _parseVariableDeclarationListAfterType(
            commentAndMetadata, keyword, type);
    Token semicolon = _expect(TokenType.SEMICOLON);
    return new VariableDeclarationStatement(variableList, semicolon);
  }

  /**
   * Parse a while statement. Return the while statement that was parsed.
   *
   *     whileStatement ::=
   *         'while' '(' expression ')' statement
   */
  Statement _parseWhileStatement() {
    bool wasInLoop = _inLoop;
    _inLoop = true;
    try {
      Token keyword = _expectKeyword(Keyword.WHILE);
      Token leftParenthesis = _expect(TokenType.OPEN_PAREN);
      Expression condition = parseExpression2();
      Token rightParenthesis = _expect(TokenType.CLOSE_PAREN);
      Statement body = parseStatement2();
      return new WhileStatement(
          keyword, leftParenthesis, condition, rightParenthesis, body);
    } finally {
      _inLoop = wasInLoop;
    }
  }

  /**
   * Parse a yield statement. Return the yield statement that was parsed.
   *
   *     yieldStatement ::=
   *         'yield' '*'? expression ';'
   */
  YieldStatement _parseYieldStatement() {
    Token yieldToken = getAndAdvance();
    Token star = null;
    if (_matches(TokenType.STAR)) {
      star = getAndAdvance();
    }
    Expression expression = parseExpression2();
    Token semicolon = _expect(TokenType.SEMICOLON);
    return new YieldStatement(yieldToken, star, expression, semicolon);
  }

  /**
   * Return the token that is immediately after the current token. This is
   * equivalent to [_peekAt](1).
   */
  Token _peek() => _currentToken.next;

  /**
   * Return the token that is the given [distance] after the current token,
   * where the distance is the number of tokens to look ahead. A distance of `0`
   * is the current token, `1` is the next token, etc.
   */
  Token _peekAt(int distance) {
    Token token = _currentToken;
    for (int i = 0; i < distance; i++) {
      token = token.next;
    }
    return token;
  }

  /**
   * Report the given [error].
   */
  void _reportError(AnalysisError error) {
    if (_errorListenerLock != 0) {
      return;
    }
    _errorListener.onError(error);
  }

  /**
   * Report an error with the given [errorCode] and [arguments] associated with
   * the current token.
   */
  void _reportErrorForCurrentToken(ParserErrorCode errorCode,
      [List<Object> arguments]) {
    _reportErrorForToken(errorCode, _currentToken, arguments);
  }

  /**
   * Report an error with the given [errorCode] and [arguments] associated with
   * the given [node].
   */
  void _reportErrorForNode(ParserErrorCode errorCode, AstNode node,
      [List<Object> arguments]) {
    _reportError(new AnalysisError(
        _source, node.offset, node.length, errorCode, arguments));
  }

  /**
   * Report an error with the given [errorCode] and [arguments] associated with
   * the given [token].
   */
  void _reportErrorForToken(ErrorCode errorCode, Token token,
      [List<Object> arguments]) {
    if (token.type == TokenType.EOF) {
      token = token.previous;
    }
    _reportError(new AnalysisError(_source, token.offset,
        math.max(token.length, 1), errorCode, arguments));
  }

  /**
   * Skips a block with all containing blocks.
   */
  void _skipBlock() {
    Token endToken = (_currentToken as BeginToken).endToken;
    if (endToken == null) {
      endToken = _currentToken.next;
      while (!identical(endToken, _currentToken)) {
        _currentToken = endToken;
        endToken = _currentToken.next;
      }
      _reportErrorForToken(
          ParserErrorCode.EXPECTED_TOKEN, _currentToken.previous, ["}"]);
    } else {
      _currentToken = endToken.next;
    }
  }

  /**
   * Parse the 'final', 'const', 'var' or type preceding a variable declaration,
   * starting at the given token, without actually creating a type or changing
   * the current token. Return the token following the type that was parsed, or
   * `null` if the given token is not the first token in a valid type. The
   * [startToken] is the token at which parsing is to begin. Return the token
   * following the type that was parsed.
   *
   * finalConstVarOrType ::=
   *   | 'final' type?
   *   | 'const' type?
   *   | 'var'
   *   | type
   */
  Token _skipFinalConstVarOrType(Token startToken) {
    if (_tokenMatchesKeyword(startToken, Keyword.FINAL) ||
        _tokenMatchesKeyword(startToken, Keyword.CONST)) {
      Token next = startToken.next;
      if (_tokenMatchesIdentifier(next)) {
        Token next2 = next.next;
        // "Type parameter" or "Type<" or "prefix.Type"
        if (_tokenMatchesIdentifier(next2) ||
            _tokenMatches(next2, TokenType.LT) ||
            _tokenMatches(next2, TokenType.PERIOD)) {
          return _skipTypeName(next);
        }
        // "parameter"
        return next;
      }
    } else if (_tokenMatchesKeyword(startToken, Keyword.VAR)) {
      return startToken.next;
    } else if (_tokenMatchesIdentifier(startToken)) {
      Token next = startToken.next;
      if (_tokenMatchesIdentifier(next) ||
          _tokenMatches(next, TokenType.LT) ||
          _tokenMatchesKeyword(next, Keyword.THIS) ||
          (_tokenMatches(next, TokenType.PERIOD) &&
              _tokenMatchesIdentifier(next.next) &&
              (_tokenMatchesIdentifier(next.next.next) ||
                  _tokenMatches(next.next.next, TokenType.LT) ||
                  _tokenMatchesKeyword(next.next.next, Keyword.THIS)))) {
        return _skipReturnType(startToken);
      }
    }
    return null;
  }

  /**
   * Parse a list of formal parameters, starting at the [startToken], without
   * actually creating a formal parameter list or changing the current token.
   * Return the token following the formal parameter list that was parsed, or
   * `null` if the given token is not the first token in a valid list of formal
   * parameter.
   *
   * Note that unlike other skip methods, this method uses a heuristic. In the
   * worst case, the parameters could be prefixed by metadata, which would
   * require us to be able to skip arbitrary expressions. Rather than duplicate
   * the logic of most of the parse methods we simply look for something that is
   * likely to be a list of parameters and then skip to returning the token
   * after the closing parenthesis.
   *
   * This method must be kept in sync with [parseFormalParameterList].
   *
   *     formalParameterList ::=
   *         '(' ')'
   *       | '(' normalFormalParameters (',' optionalFormalParameters)? ')'
   *       | '(' optionalFormalParameters ')'
   *
   *     normalFormalParameters ::=
   *         normalFormalParameter (',' normalFormalParameter)*
   *
   *     optionalFormalParameters ::=
   *         optionalPositionalFormalParameters
   *       | namedFormalParameters
   *
   *     optionalPositionalFormalParameters ::=
   *         '[' defaultFormalParameter (',' defaultFormalParameter)* ']'
   *
   *     namedFormalParameters ::=
   *         '{' defaultNamedParameter (',' defaultNamedParameter)* '}'
   */
  Token _skipFormalParameterList(Token startToken) {
    if (!_tokenMatches(startToken, TokenType.OPEN_PAREN)) {
      return null;
    }
    Token next = startToken.next;
    if (_tokenMatches(next, TokenType.CLOSE_PAREN)) {
      return next.next;
    }
    //
    // Look to see whether the token after the open parenthesis is something
    // that should only occur at the beginning of a parameter list.
    //
    if (next.matchesAny([
      TokenType.AT,
      TokenType.OPEN_SQUARE_BRACKET,
      TokenType.OPEN_CURLY_BRACKET
    ]) ||
        _tokenMatchesKeyword(next, Keyword.VOID) ||
        (_tokenMatchesIdentifier(next) &&
            (next.next.matchesAny([TokenType.COMMA, TokenType.CLOSE_PAREN])))) {
      return _skipPastMatchingToken(startToken);
    }
    //
    // Look to see whether the first parameter is a function typed parameter
    // without a return type.
    //
    if (_tokenMatchesIdentifier(next) &&
        _tokenMatches(next.next, TokenType.OPEN_PAREN)) {
      Token afterParameters = _skipFormalParameterList(next.next);
      if (afterParameters != null &&
          (afterParameters
              .matchesAny([TokenType.COMMA, TokenType.CLOSE_PAREN]))) {
        return _skipPastMatchingToken(startToken);
      }
    }
    //
    // Look to see whether the first parameter has a type or is a function typed
    // parameter with a return type.
    //
    Token afterType = _skipFinalConstVarOrType(next);
    if (afterType == null) {
      return null;
    }
    if (_skipSimpleIdentifier(afterType) == null) {
      return null;
    }
    return _skipPastMatchingToken(startToken);
  }

  /**
   * If the [startToken] is a begin token with an associated end token, then
   * return the token following the end token. Otherwise, return `null`.
   */
  Token _skipPastMatchingToken(Token startToken) {
    if (startToken is! BeginToken) {
      return null;
    }
    Token closeParen = (startToken as BeginToken).endToken;
    if (closeParen == null) {
      return null;
    }
    return closeParen.next;
  }

  /**
   * Parse a prefixed identifier, starting at the [startToken], without actually
   * creating a prefixed identifier or changing the current token. Return the
   * token following the prefixed identifier that was parsed, or `null` if the
   * given token is not the first token in a valid prefixed identifier.
   *
   * This method must be kept in sync with [parsePrefixedIdentifier].
   *
   *     prefixedIdentifier ::=
   *         identifier ('.' identifier)?
   */
  Token _skipPrefixedIdentifier(Token startToken) {
    Token token = _skipSimpleIdentifier(startToken);
    if (token == null) {
      return null;
    } else if (!_tokenMatches(token, TokenType.PERIOD)) {
      return token;
    }
    token = token.next;
    Token nextToken = _skipSimpleIdentifier(token);
    if (nextToken != null) {
      return nextToken;
    } else if (_tokenMatches(token, TokenType.CLOSE_PAREN) ||
        _tokenMatches(token, TokenType.COMMA)) {
      // If the `id.` is followed by something that cannot produce a valid
      // structure then assume this is a prefixed identifier but missing the
      // trailing identifier
      return token;
    }
    return null;
  }

  /**
   * Parse a return type, starting at the [startToken], without actually
   * creating a return type or changing the current token. Return the token
   * following the return type that was parsed, or `null` if the given token is
   * not the first token in a valid return type.
   *
   * This method must be kept in sync with [parseReturnType].
   *
   *     returnType ::=
   *         'void'
   *       | type
   */
  Token _skipReturnType(Token startToken) {
    if (_tokenMatchesKeyword(startToken, Keyword.VOID)) {
      return startToken.next;
    } else {
      return _skipTypeName(startToken);
    }
  }

  /**
   * Parse a simple identifier, starting at the [startToken], without actually
   * creating a simple identifier or changing the current token. Return the
   * token following the simple identifier that was parsed, or `null` if the
   * given token is not the first token in a valid simple identifier.
   *
   * This method must be kept in sync with [parseSimpleIdentifier].
   *
   *     identifier ::=
   *         IDENTIFIER
   */
  Token _skipSimpleIdentifier(Token startToken) {
    if (_tokenMatches(startToken, TokenType.IDENTIFIER) ||
        (_tokenMatches(startToken, TokenType.KEYWORD) &&
            (startToken as KeywordToken).keyword.isPseudoKeyword)) {
      return startToken.next;
    }
    return null;
  }

  /**
   * Parse a string literal that contains interpolations, starting at the
   * [startToken], without actually creating a string literal or changing the
   * current token. Return the token following the string literal that was
   * parsed, or `null` if the given token is not the first token in a valid
   * string literal.
   *
   * This method must be kept in sync with [parseStringInterpolation].
   */
  Token _skipStringInterpolation(Token startToken) {
    Token token = startToken;
    TokenType type = token.type;
    while (type == TokenType.STRING_INTERPOLATION_EXPRESSION ||
        type == TokenType.STRING_INTERPOLATION_IDENTIFIER) {
      if (type == TokenType.STRING_INTERPOLATION_EXPRESSION) {
        token = token.next;
        type = token.type;
        //
        // Rather than verify that the following tokens represent a valid
        // expression, we simply skip tokens until we reach the end of the
        // interpolation, being careful to handle nested string literals.
        //
        int bracketNestingLevel = 1;
        while (bracketNestingLevel > 0) {
          if (type == TokenType.EOF) {
            return null;
          } else if (type == TokenType.OPEN_CURLY_BRACKET) {
            bracketNestingLevel++;
          } else if (type == TokenType.CLOSE_CURLY_BRACKET) {
            bracketNestingLevel--;
          } else if (type == TokenType.STRING) {
            token = _skipStringLiteral(token);
            if (token == null) {
              return null;
            }
          } else {
            token = token.next;
          }
          type = token.type;
        }
        token = token.next;
        type = token.type;
      } else {
        token = token.next;
        if (token.type != TokenType.IDENTIFIER) {
          return null;
        }
        token = token.next;
      }
      type = token.type;
      if (type == TokenType.STRING) {
        token = token.next;
        type = token.type;
      }
    }
    return token;
  }

  /**
   * Parse a string literal, starting at the [startToken], without actually
   * creating a string literal or changing the current token. Return the token
   * following the string literal that was parsed, or `null` if the given token
   * is not the first token in a valid string literal.
   *
   * This method must be kept in sync with [parseStringLiteral].
   *
   *     stringLiteral ::=
   *         MULTI_LINE_STRING+
   *       | SINGLE_LINE_STRING+
   */
  Token _skipStringLiteral(Token startToken) {
    Token token = startToken;
    while (token != null && _tokenMatches(token, TokenType.STRING)) {
      token = token.next;
      TokenType type = token.type;
      if (type == TokenType.STRING_INTERPOLATION_EXPRESSION ||
          type == TokenType.STRING_INTERPOLATION_IDENTIFIER) {
        token = _skipStringInterpolation(token);
      }
    }
    if (identical(token, startToken)) {
      return null;
    }
    return token;
  }

  /**
   * Parse a list of type arguments, starting at the [startToken], without
   * actually creating a type argument list or changing the current token.
   * Return the token following the type argument list that was parsed, or
   * `null` if the given token is not the first token in a valid type argument
   * list.
   *
   * This method must be kept in sync with [parseTypeArgumentList].
   *
   *     typeArguments ::=
   *         '<' typeList '>'
   *
   *     typeList ::=
   *         type (',' type)*
   */
  Token _skipTypeArgumentList(Token startToken) {
    Token token = startToken;
    if (!_tokenMatches(token, TokenType.LT)) {
      return null;
    }
    token = _skipTypeName(token.next);
    if (token == null) {
      // If the start token '<' is followed by '>'
      // then assume this should be type argument list but is missing a type
      token = startToken.next;
      if (_tokenMatches(token, TokenType.GT)) {
        return token.next;
      }
      return null;
    }
    while (_tokenMatches(token, TokenType.COMMA)) {
      token = _skipTypeName(token.next);
      if (token == null) {
        return null;
      }
    }
    if (token.type == TokenType.GT) {
      return token.next;
    } else if (token.type == TokenType.GT_GT) {
      Token second = new Token(TokenType.GT, token.offset + 1);
      second.setNextWithoutSettingPrevious(token.next);
      return second;
    }
    return null;
  }

  /**
   * Parse a type name, starting at the [startToken], without actually creating
   * a type name or changing the current token. Return the token following the
   * type name that was parsed, or `null` if the given token is not the first
   * token in a valid type name.
   *
   * This method must be kept in sync with [parseTypeName].
   *
   *     type ::=
   *         qualified typeArguments?
   */
  Token _skipTypeName(Token startToken) {
    Token token = _skipPrefixedIdentifier(startToken);
    if (token == null) {
      return null;
    }
    if (_tokenMatches(token, TokenType.LT)) {
      token = _skipTypeArgumentList(token);
    }
    return token;
  }

  /**
   * Parse a list of type parameters, starting at the [startToken], without
   * actually creating a type parameter list or changing the current token.
   * Return the token following the type parameter list that was parsed, or
   * `null` if the given token is not the first token in a valid type parameter
   * list.
   *
   * This method must be kept in sync with [parseTypeParameterList].
   *
   *     typeParameterList ::=
   *         '<' typeParameter (',' typeParameter)* '>'
   */
  Token _skipTypeParameterList(Token startToken) {
    if (!_tokenMatches(startToken, TokenType.LT)) {
      return null;
    }
    //
    // We can't skip a type parameter because it can be preceeded by metadata,
    // so we just assume that everything before the matching end token is valid.
    //
    int depth = 1;
    Token next = startToken.next;
    while (depth > 0) {
      if (_tokenMatches(next, TokenType.EOF)) {
        return null;
      } else if (_tokenMatches(next, TokenType.LT)) {
        depth++;
      } else if (_tokenMatches(next, TokenType.GT)) {
        depth--;
      } else if (_tokenMatches(next, TokenType.GT_EQ)) {
        if (depth == 1) {
          Token fakeEquals = new Token(TokenType.EQ, next.offset + 2);
          fakeEquals.setNextWithoutSettingPrevious(next.next);
          return fakeEquals;
        }
        depth--;
      } else if (_tokenMatches(next, TokenType.GT_GT)) {
        depth -= 2;
      } else if (_tokenMatches(next, TokenType.GT_GT_EQ)) {
        if (depth < 2) {
          return null;
        } else if (depth == 2) {
          Token fakeEquals = new Token(TokenType.EQ, next.offset + 2);
          fakeEquals.setNextWithoutSettingPrevious(next.next);
          return fakeEquals;
        }
        depth -= 2;
      }
      next = next.next;
    }
    return next;
  }

  /**
   * Return `true` if the given [token] has the given [type].
   */
  bool _tokenMatches(Token token, TokenType type) => token.type == type;

  /**
   * Return `true` if the given [token] is a valid identifier. Valid identifiers
   * include built-in identifiers (pseudo-keywords).
   */
  bool _tokenMatchesIdentifier(Token token) =>
      _tokenMatches(token, TokenType.IDENTIFIER) ||
          (_tokenMatches(token, TokenType.KEYWORD) &&
              (token as KeywordToken).keyword.isPseudoKeyword);

  /**
   * Return `true` if the given [token] matches the given [keyword].
   */
  bool _tokenMatchesKeyword(Token token, Keyword keyword) =>
      token.type == TokenType.KEYWORD &&
          (token as KeywordToken).keyword == keyword;

  /**
   * Return `true` if the given [token] matches the given [identifier].
   */
  bool _tokenMatchesString(Token token, String identifier) =>
      token.type == TokenType.IDENTIFIER && token.lexeme == identifier;

  /**
   * Translate the characters at the given [index] in the given [lexeme],
   * appending the translated character to the given [buffer]. The index is
   * assumed to be valid.
   */
  int _translateCharacter(StringBuffer buffer, String lexeme, int index) {
    int currentChar = lexeme.codeUnitAt(index);
    if (currentChar != 0x5C) {
      buffer.writeCharCode(currentChar);
      return index + 1;
    }
    //
    // We have found an escape sequence, so we parse the string to determine
    // what kind of escape sequence and what character to add to the builder.
    //
    int length = lexeme.length;
    int currentIndex = index + 1;
    if (currentIndex >= length) {
      // Illegal escape sequence: no char after escape.
      // This cannot actually happen because it would require the escape
      // character to be the last character in the string, but if it were it
      // would escape the closing quote, leaving the string unclosed.
      // reportError(ParserErrorCode.MISSING_CHAR_IN_ESCAPE_SEQUENCE);
      return length;
    }
    currentChar = lexeme.codeUnitAt(currentIndex);
    if (currentChar == 0x6E) {
      buffer.writeCharCode(0xA);
      // newline
    } else if (currentChar == 0x72) {
      buffer.writeCharCode(0xD);
      // carriage return
    } else if (currentChar == 0x66) {
      buffer.writeCharCode(0xC);
      // form feed
    } else if (currentChar == 0x62) {
      buffer.writeCharCode(0x8);
      // backspace
    } else if (currentChar == 0x74) {
      buffer.writeCharCode(0x9);
      // tab
    } else if (currentChar == 0x76) {
      buffer.writeCharCode(0xB);
      // vertical tab
    } else if (currentChar == 0x78) {
      if (currentIndex + 2 >= length) {
        // Illegal escape sequence: not enough hex digits
        _reportErrorForCurrentToken(ParserErrorCode.INVALID_HEX_ESCAPE);
        return length;
      }
      int firstDigit = lexeme.codeUnitAt(currentIndex + 1);
      int secondDigit = lexeme.codeUnitAt(currentIndex + 2);
      if (!_isHexDigit(firstDigit) || !_isHexDigit(secondDigit)) {
        // Illegal escape sequence: invalid hex digit
        _reportErrorForCurrentToken(ParserErrorCode.INVALID_HEX_ESCAPE);
      } else {
        int charCode = (Character.digit(firstDigit, 16) << 4) +
            Character.digit(secondDigit, 16);
        buffer.writeCharCode(charCode);
      }
      return currentIndex + 3;
    } else if (currentChar == 0x75) {
      currentIndex++;
      if (currentIndex >= length) {
        // Illegal escape sequence: not enough hex digits
        _reportErrorForCurrentToken(ParserErrorCode.INVALID_UNICODE_ESCAPE);
        return length;
      }
      currentChar = lexeme.codeUnitAt(currentIndex);
      if (currentChar == 0x7B) {
        currentIndex++;
        if (currentIndex >= length) {
          // Illegal escape sequence: incomplete escape
          _reportErrorForCurrentToken(ParserErrorCode.INVALID_UNICODE_ESCAPE);
          return length;
        }
        currentChar = lexeme.codeUnitAt(currentIndex);
        int digitCount = 0;
        int value = 0;
        while (currentChar != 0x7D) {
          if (!_isHexDigit(currentChar)) {
            // Illegal escape sequence: invalid hex digit
            _reportErrorForCurrentToken(ParserErrorCode.INVALID_UNICODE_ESCAPE);
            currentIndex++;
            while (currentIndex < length &&
                lexeme.codeUnitAt(currentIndex) != 0x7D) {
              currentIndex++;
            }
            return currentIndex + 1;
          }
          digitCount++;
          value = (value << 4) + Character.digit(currentChar, 16);
          currentIndex++;
          if (currentIndex >= length) {
            // Illegal escape sequence: incomplete escape
            _reportErrorForCurrentToken(ParserErrorCode.INVALID_UNICODE_ESCAPE);
            return length;
          }
          currentChar = lexeme.codeUnitAt(currentIndex);
        }
        if (digitCount < 1 || digitCount > 6) {
          // Illegal escape sequence: not enough or too many hex digits
          _reportErrorForCurrentToken(ParserErrorCode.INVALID_UNICODE_ESCAPE);
        }
        _appendScalarValue(buffer, lexeme.substring(index, currentIndex + 1),
            value, index, currentIndex);
        return currentIndex + 1;
      } else {
        if (currentIndex + 3 >= length) {
          // Illegal escape sequence: not enough hex digits
          _reportErrorForCurrentToken(ParserErrorCode.INVALID_UNICODE_ESCAPE);
          return length;
        }
        int firstDigit = currentChar;
        int secondDigit = lexeme.codeUnitAt(currentIndex + 1);
        int thirdDigit = lexeme.codeUnitAt(currentIndex + 2);
        int fourthDigit = lexeme.codeUnitAt(currentIndex + 3);
        if (!_isHexDigit(firstDigit) ||
            !_isHexDigit(secondDigit) ||
            !_isHexDigit(thirdDigit) ||
            !_isHexDigit(fourthDigit)) {
          // Illegal escape sequence: invalid hex digits
          _reportErrorForCurrentToken(ParserErrorCode.INVALID_UNICODE_ESCAPE);
        } else {
          _appendScalarValue(
              buffer,
              lexeme
                  .substring(
                      index,
                      currentIndex + 1),
              (((((Character.digit(firstDigit, 16) << 4) +
                                  Character.digit(secondDigit, 16)) <<
                              4) +
                          Character.digit(thirdDigit, 16)) <<
                      4) +
                  Character
                      .digit(fourthDigit, 16),
              index,
              currentIndex +
                  3);
        }
        return currentIndex + 4;
      }
    } else {
      buffer.writeCharCode(currentChar);
    }
    return currentIndex + 1;
  }

  /**
   * Decrements the error reporting lock level. If level is more than `0`, then
   * [reportError] wont report any error.
   */
  void _unlockErrorListener() {
    if (_errorListenerLock == 0) {
      throw new IllegalStateException(
          "Attempt to unlock not locked error listener.");
    }
    _errorListenerLock--;
  }

  /**
   * Validate that the given [parameterList] does not contain any field
   * initializers.
   */
  void _validateFormalParameterList(FormalParameterList parameterList) {
    for (FormalParameter parameter in parameterList.parameters) {
      if (parameter is FieldFormalParameter) {
        _reportErrorForNode(
            ParserErrorCode.FIELD_INITIALIZER_OUTSIDE_CONSTRUCTOR,
            parameter.identifier);
      }
    }
  }

  /**
   * Validate that the given set of [modifiers] is appropriate for a class and
   * return the 'abstract' keyword if there is one.
   */
  Token _validateModifiersForClass(Modifiers modifiers) {
    _validateModifiersForTopLevelDeclaration(modifiers);
    if (modifiers.constKeyword != null) {
      _reportErrorForToken(ParserErrorCode.CONST_CLASS, modifiers.constKeyword);
    }
    if (modifiers.externalKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.EXTERNAL_CLASS, modifiers.externalKeyword);
    }
    if (modifiers.finalKeyword != null) {
      _reportErrorForToken(ParserErrorCode.FINAL_CLASS, modifiers.finalKeyword);
    }
    if (modifiers.varKeyword != null) {
      _reportErrorForToken(ParserErrorCode.VAR_CLASS, modifiers.varKeyword);
    }
    return modifiers.abstractKeyword;
  }

  /**
   * Validate that the given set of [modifiers] is appropriate for a constructor
   * and return the 'const' keyword if there is one.
   */
  Token _validateModifiersForConstructor(Modifiers modifiers) {
    if (modifiers.abstractKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.ABSTRACT_CLASS_MEMBER, modifiers.abstractKeyword);
    }
    if (modifiers.finalKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.FINAL_CONSTRUCTOR, modifiers.finalKeyword);
    }
    if (modifiers.staticKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.STATIC_CONSTRUCTOR, modifiers.staticKeyword);
    }
    if (modifiers.varKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.CONSTRUCTOR_WITH_RETURN_TYPE, modifiers.varKeyword);
    }
    Token externalKeyword = modifiers.externalKeyword;
    Token constKeyword = modifiers.constKeyword;
    Token factoryKeyword = modifiers.factoryKeyword;
    if (externalKeyword != null &&
        constKeyword != null &&
        constKeyword.offset < externalKeyword.offset) {
      _reportErrorForToken(
          ParserErrorCode.EXTERNAL_AFTER_CONST, externalKeyword);
    }
    if (externalKeyword != null &&
        factoryKeyword != null &&
        factoryKeyword.offset < externalKeyword.offset) {
      _reportErrorForToken(
          ParserErrorCode.EXTERNAL_AFTER_FACTORY, externalKeyword);
    }
    return constKeyword;
  }

  /**
   * Validate that the given set of [modifiers] is appropriate for a class and
   * return the 'abstract' keyword if there is one.
   */
  void _validateModifiersForEnum(Modifiers modifiers) {
    _validateModifiersForTopLevelDeclaration(modifiers);
    if (modifiers.abstractKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.ABSTRACT_ENUM, modifiers.abstractKeyword);
    }
    if (modifiers.constKeyword != null) {
      _reportErrorForToken(ParserErrorCode.CONST_ENUM, modifiers.constKeyword);
    }
    if (modifiers.externalKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.EXTERNAL_ENUM, modifiers.externalKeyword);
    }
    if (modifiers.finalKeyword != null) {
      _reportErrorForToken(ParserErrorCode.FINAL_ENUM, modifiers.finalKeyword);
    }
    if (modifiers.varKeyword != null) {
      _reportErrorForToken(ParserErrorCode.VAR_ENUM, modifiers.varKeyword);
    }
  }

  /**
   * Validate that the given set of [modifiers] is appropriate for a field and
   * return the 'final', 'const' or 'var' keyword if there is one.
   */
  Token _validateModifiersForField(Modifiers modifiers) {
    if (modifiers.abstractKeyword != null) {
      _reportErrorForCurrentToken(ParserErrorCode.ABSTRACT_CLASS_MEMBER);
    }
    if (modifiers.externalKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.EXTERNAL_FIELD, modifiers.externalKeyword);
    }
    if (modifiers.factoryKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.NON_CONSTRUCTOR_FACTORY, modifiers.factoryKeyword);
    }
    Token staticKeyword = modifiers.staticKeyword;
    Token constKeyword = modifiers.constKeyword;
    Token finalKeyword = modifiers.finalKeyword;
    Token varKeyword = modifiers.varKeyword;
    if (constKeyword != null) {
      if (finalKeyword != null) {
        _reportErrorForToken(ParserErrorCode.CONST_AND_FINAL, finalKeyword);
      }
      if (varKeyword != null) {
        _reportErrorForToken(ParserErrorCode.CONST_AND_VAR, varKeyword);
      }
      if (staticKeyword != null && constKeyword.offset < staticKeyword.offset) {
        _reportErrorForToken(ParserErrorCode.STATIC_AFTER_CONST, staticKeyword);
      }
    } else if (finalKeyword != null) {
      if (varKeyword != null) {
        _reportErrorForToken(ParserErrorCode.FINAL_AND_VAR, varKeyword);
      }
      if (staticKeyword != null && finalKeyword.offset < staticKeyword.offset) {
        _reportErrorForToken(ParserErrorCode.STATIC_AFTER_FINAL, staticKeyword);
      }
    } else if (varKeyword != null &&
        staticKeyword != null &&
        varKeyword.offset < staticKeyword.offset) {
      _reportErrorForToken(ParserErrorCode.STATIC_AFTER_VAR, staticKeyword);
    }
    return Token.lexicallyFirst([constKeyword, finalKeyword, varKeyword]);
  }

  /**
   * Validate that the given set of [modifiers] is appropriate for a local
   * function.
   */
  void _validateModifiersForFunctionDeclarationStatement(Modifiers modifiers) {
    if (modifiers.abstractKeyword != null ||
        modifiers.constKeyword != null ||
        modifiers.externalKeyword != null ||
        modifiers.factoryKeyword != null ||
        modifiers.finalKeyword != null ||
        modifiers.staticKeyword != null ||
        modifiers.varKeyword != null) {
      _reportErrorForCurrentToken(
          ParserErrorCode.LOCAL_FUNCTION_DECLARATION_MODIFIER);
    }
  }

  /**
   * Validate that the given set of [modifiers] is appropriate for a getter,
   * setter, or method.
   */
  void _validateModifiersForGetterOrSetterOrMethod(Modifiers modifiers) {
    if (modifiers.abstractKeyword != null) {
      _reportErrorForCurrentToken(ParserErrorCode.ABSTRACT_CLASS_MEMBER);
    }
    if (modifiers.constKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.CONST_METHOD, modifiers.constKeyword);
    }
    if (modifiers.factoryKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.NON_CONSTRUCTOR_FACTORY, modifiers.factoryKeyword);
    }
    if (modifiers.finalKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.FINAL_METHOD, modifiers.finalKeyword);
    }
    if (modifiers.varKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.VAR_RETURN_TYPE, modifiers.varKeyword);
    }
    Token externalKeyword = modifiers.externalKeyword;
    Token staticKeyword = modifiers.staticKeyword;
    if (externalKeyword != null &&
        staticKeyword != null &&
        staticKeyword.offset < externalKeyword.offset) {
      _reportErrorForToken(
          ParserErrorCode.EXTERNAL_AFTER_STATIC, externalKeyword);
    }
  }

  /**
   * Validate that the given set of [modifiers] is appropriate for a getter,
   * setter, or method.
   */
  void _validateModifiersForOperator(Modifiers modifiers) {
    if (modifiers.abstractKeyword != null) {
      _reportErrorForCurrentToken(ParserErrorCode.ABSTRACT_CLASS_MEMBER);
    }
    if (modifiers.constKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.CONST_METHOD, modifiers.constKeyword);
    }
    if (modifiers.factoryKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.NON_CONSTRUCTOR_FACTORY, modifiers.factoryKeyword);
    }
    if (modifiers.finalKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.FINAL_METHOD, modifiers.finalKeyword);
    }
    if (modifiers.staticKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.STATIC_OPERATOR, modifiers.staticKeyword);
    }
    if (modifiers.varKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.VAR_RETURN_TYPE, modifiers.varKeyword);
    }
  }

  /**
   * Validate that the given set of [modifiers] is appropriate for a top-level
   * declaration.
   */
  void _validateModifiersForTopLevelDeclaration(Modifiers modifiers) {
    if (modifiers.factoryKeyword != null) {
      _reportErrorForToken(ParserErrorCode.FACTORY_TOP_LEVEL_DECLARATION,
          modifiers.factoryKeyword);
    }
    if (modifiers.staticKeyword != null) {
      _reportErrorForToken(ParserErrorCode.STATIC_TOP_LEVEL_DECLARATION,
          modifiers.staticKeyword);
    }
  }

  /**
   * Validate that the given set of [modifiers] is appropriate for a top-level
   * function.
   */
  void _validateModifiersForTopLevelFunction(Modifiers modifiers) {
    _validateModifiersForTopLevelDeclaration(modifiers);
    if (modifiers.abstractKeyword != null) {
      _reportErrorForCurrentToken(ParserErrorCode.ABSTRACT_TOP_LEVEL_FUNCTION);
    }
    if (modifiers.constKeyword != null) {
      _reportErrorForToken(ParserErrorCode.CONST_CLASS, modifiers.constKeyword);
    }
    if (modifiers.finalKeyword != null) {
      _reportErrorForToken(ParserErrorCode.FINAL_CLASS, modifiers.finalKeyword);
    }
    if (modifiers.varKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.VAR_RETURN_TYPE, modifiers.varKeyword);
    }
  }

  /**
   * Validate that the given set of [modifiers] is appropriate for a field and
   * return the 'final', 'const' or 'var' keyword if there is one.
   */
  Token _validateModifiersForTopLevelVariable(Modifiers modifiers) {
    _validateModifiersForTopLevelDeclaration(modifiers);
    if (modifiers.abstractKeyword != null) {
      _reportErrorForCurrentToken(ParserErrorCode.ABSTRACT_TOP_LEVEL_VARIABLE);
    }
    if (modifiers.externalKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.EXTERNAL_FIELD, modifiers.externalKeyword);
    }
    Token constKeyword = modifiers.constKeyword;
    Token finalKeyword = modifiers.finalKeyword;
    Token varKeyword = modifiers.varKeyword;
    if (constKeyword != null) {
      if (finalKeyword != null) {
        _reportErrorForToken(ParserErrorCode.CONST_AND_FINAL, finalKeyword);
      }
      if (varKeyword != null) {
        _reportErrorForToken(ParserErrorCode.CONST_AND_VAR, varKeyword);
      }
    } else if (finalKeyword != null) {
      if (varKeyword != null) {
        _reportErrorForToken(ParserErrorCode.FINAL_AND_VAR, varKeyword);
      }
    }
    return Token.lexicallyFirst([constKeyword, finalKeyword, varKeyword]);
  }

  /**
   * Validate that the given set of [modifiers] is appropriate for a class and
   * return the 'abstract' keyword if there is one.
   */
  void _validateModifiersForTypedef(Modifiers modifiers) {
    _validateModifiersForTopLevelDeclaration(modifiers);
    if (modifiers.abstractKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.ABSTRACT_TYPEDEF, modifiers.abstractKeyword);
    }
    if (modifiers.constKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.CONST_TYPEDEF, modifiers.constKeyword);
    }
    if (modifiers.externalKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.EXTERNAL_TYPEDEF, modifiers.externalKeyword);
    }
    if (modifiers.finalKeyword != null) {
      _reportErrorForToken(
          ParserErrorCode.FINAL_TYPEDEF, modifiers.finalKeyword);
    }
    if (modifiers.varKeyword != null) {
      _reportErrorForToken(ParserErrorCode.VAR_TYPEDEF, modifiers.varKeyword);
    }
  }
}
/**
 * A synthetic keyword token.
 */
class Parser_SyntheticKeywordToken extends KeywordToken {
  /**
   * Initialize a newly created token to represent the given [keyword] at the
   * given [offset].
   */
  Parser_SyntheticKeywordToken(Keyword keyword, int offset)
      : super(keyword, offset);

  @override
  int get length => 0;

  @override
  Token copy() => new Parser_SyntheticKeywordToken(keyword, offset);
}

/**
 * The error codes used for errors detected by the parser. The convention for
 * this class is for the name of the error code to indicate the problem that
 * caused the error to be generated and for the error message to explain what
 * is wrong and, when appropriate, how the problem can be corrected.
 */
class ParserErrorCode extends ErrorCode {
  static const ParserErrorCode ABSTRACT_CLASS_MEMBER = const ParserErrorCode(
      'ABSTRACT_CLASS_MEMBER',
      "Members of classes cannot be declared to be 'abstract'");

  static const ParserErrorCode ABSTRACT_ENUM = const ParserErrorCode(
      'ABSTRACT_ENUM', "Enums cannot be declared to be 'abstract'");

  static const ParserErrorCode ABSTRACT_STATIC_METHOD = const ParserErrorCode(
      'ABSTRACT_STATIC_METHOD',
      "Static methods cannot be declared to be 'abstract'");

  static const ParserErrorCode ABSTRACT_TOP_LEVEL_FUNCTION =
      const ParserErrorCode('ABSTRACT_TOP_LEVEL_FUNCTION',
          "Top-level functions cannot be declared to be 'abstract'");

  static const ParserErrorCode ABSTRACT_TOP_LEVEL_VARIABLE =
      const ParserErrorCode('ABSTRACT_TOP_LEVEL_VARIABLE',
          "Top-level variables cannot be declared to be 'abstract'");

  static const ParserErrorCode ABSTRACT_TYPEDEF = const ParserErrorCode(
      'ABSTRACT_TYPEDEF', "Type aliases cannot be declared to be 'abstract'");

  static const ParserErrorCode ANNOTATION_ON_ENUM_CONSTANT =
      const ParserErrorCode('ANNOTATION_ON_ENUM_CONSTANT',
          "Enum constants cannot have annotations");

  static const ParserErrorCode ASSERT_DOES_NOT_TAKE_ASSIGNMENT =
      const ParserErrorCode('ASSERT_DOES_NOT_TAKE_ASSIGNMENT',
          "Assert cannot be called on an assignment");

  static const ParserErrorCode ASSERT_DOES_NOT_TAKE_CASCADE =
      const ParserErrorCode(
          'ASSERT_DOES_NOT_TAKE_CASCADE', "Assert cannot be called on cascade");

  static const ParserErrorCode ASSERT_DOES_NOT_TAKE_THROW =
      const ParserErrorCode(
          'ASSERT_DOES_NOT_TAKE_THROW', "Assert cannot be called on throws");

  static const ParserErrorCode ASSERT_DOES_NOT_TAKE_RETHROW =
      const ParserErrorCode('ASSERT_DOES_NOT_TAKE_RETHROW',
          "Assert cannot be called on rethrows");

  /**
   * 16.32 Identifier Reference: It is a compile-time error if any of the
   * identifiers async, await, or yield is used as an identifier in a function
   * body marked with either async, async*, or sync*.
   */
  static const ParserErrorCode ASYNC_KEYWORD_USED_AS_IDENTIFIER =
      const ParserErrorCode('ASYNC_KEYWORD_USED_AS_IDENTIFIER',
          "The keywords 'async', 'await', and 'yield' may not be used as identifiers in an asynchronous or generator function.");

  static const ParserErrorCode BREAK_OUTSIDE_OF_LOOP = const ParserErrorCode(
      'BREAK_OUTSIDE_OF_LOOP',
      "A break statement cannot be used outside of a loop or switch statement");

  static const ParserErrorCode CLASS_IN_CLASS = const ParserErrorCode(
      'CLASS_IN_CLASS', "Classes cannot be declared inside other classes");

  static const ParserErrorCode COLON_IN_PLACE_OF_IN = const ParserErrorCode(
      'COLON_IN_PLACE_OF_IN', "For-in loops use 'in' rather than a colon");

  static const ParserErrorCode CONST_AND_FINAL = const ParserErrorCode(
      'CONST_AND_FINAL',
      "Members cannot be declared to be both 'const' and 'final'");

  static const ParserErrorCode CONST_AND_VAR = const ParserErrorCode(
      'CONST_AND_VAR',
      "Members cannot be declared to be both 'const' and 'var'");

  static const ParserErrorCode CONST_CLASS = const ParserErrorCode(
      'CONST_CLASS', "Classes cannot be declared to be 'const'");

  static const ParserErrorCode CONST_CONSTRUCTOR_WITH_BODY =
      const ParserErrorCode('CONST_CONSTRUCTOR_WITH_BODY',
          "'const' constructors cannot have a body");

  static const ParserErrorCode CONST_ENUM = const ParserErrorCode(
      'CONST_ENUM', "Enums cannot be declared to be 'const'");

  static const ParserErrorCode CONST_FACTORY = const ParserErrorCode(
      'CONST_FACTORY',
      "Only redirecting factory constructors can be declared to be 'const'");

  static const ParserErrorCode CONST_METHOD = const ParserErrorCode(
      'CONST_METHOD',
      "Getters, setters and methods cannot be declared to be 'const'");

  static const ParserErrorCode CONST_TYPEDEF = const ParserErrorCode(
      'CONST_TYPEDEF', "Type aliases cannot be declared to be 'const'");

  static const ParserErrorCode CONSTRUCTOR_WITH_RETURN_TYPE =
      const ParserErrorCode('CONSTRUCTOR_WITH_RETURN_TYPE',
          "Constructors cannot have a return type");

  static const ParserErrorCode CONTINUE_OUTSIDE_OF_LOOP = const ParserErrorCode(
      'CONTINUE_OUTSIDE_OF_LOOP',
      "A continue statement cannot be used outside of a loop or switch statement");

  static const ParserErrorCode CONTINUE_WITHOUT_LABEL_IN_CASE =
      const ParserErrorCode('CONTINUE_WITHOUT_LABEL_IN_CASE',
          "A continue statement in a switch statement must have a label as a target");

  static const ParserErrorCode DEPRECATED_CLASS_TYPE_ALIAS =
      const ParserErrorCode('DEPRECATED_CLASS_TYPE_ALIAS',
          "The 'typedef' mixin application was replaced with 'class'");

  static const ParserErrorCode DIRECTIVE_AFTER_DECLARATION =
      const ParserErrorCode('DIRECTIVE_AFTER_DECLARATION',
          "Directives must appear before any declarations");

  static const ParserErrorCode DUPLICATE_LABEL_IN_SWITCH_STATEMENT =
      const ParserErrorCode('DUPLICATE_LABEL_IN_SWITCH_STATEMENT',
          "The label {0} was already used in this switch statement");

  static const ParserErrorCode DUPLICATED_MODIFIER = const ParserErrorCode(
      'DUPLICATED_MODIFIER', "The modifier '{0}' was already specified.");

  static const ParserErrorCode EMPTY_ENUM_BODY = const ParserErrorCode(
      'EMPTY_ENUM_BODY', "An enum must declare at least one constant name");

  static const ParserErrorCode ENUM_IN_CLASS = const ParserErrorCode(
      'ENUM_IN_CLASS', "Enums cannot be declared inside classes");

  static const ParserErrorCode EQUALITY_CANNOT_BE_EQUALITY_OPERAND =
      const ParserErrorCode('EQUALITY_CANNOT_BE_EQUALITY_OPERAND',
          "Equality expression cannot be operand of another equality expression.");

  static const ParserErrorCode EXPECTED_CASE_OR_DEFAULT = const ParserErrorCode(
      'EXPECTED_CASE_OR_DEFAULT', "Expected 'case' or 'default'");

  static const ParserErrorCode EXPECTED_CLASS_MEMBER =
      const ParserErrorCode('EXPECTED_CLASS_MEMBER', "Expected a class member");

  static const ParserErrorCode EXPECTED_EXECUTABLE = const ParserErrorCode(
      'EXPECTED_EXECUTABLE',
      "Expected a method, getter, setter or operator declaration");

  static const ParserErrorCode EXPECTED_LIST_OR_MAP_LITERAL =
      const ParserErrorCode(
          'EXPECTED_LIST_OR_MAP_LITERAL', "Expected a list or map literal");

  static const ParserErrorCode EXPECTED_STRING_LITERAL = const ParserErrorCode(
      'EXPECTED_STRING_LITERAL', "Expected a string literal");

  static const ParserErrorCode EXPECTED_TOKEN =
      const ParserErrorCode('EXPECTED_TOKEN', "Expected to find '{0}'");

  static const ParserErrorCode EXPECTED_TYPE_NAME =
      const ParserErrorCode('EXPECTED_TYPE_NAME', "Expected a type name");

  static const ParserErrorCode EXPORT_DIRECTIVE_AFTER_PART_DIRECTIVE =
      const ParserErrorCode('EXPORT_DIRECTIVE_AFTER_PART_DIRECTIVE',
          "Export directives must preceed part directives");

  static const ParserErrorCode EXTERNAL_AFTER_CONST = const ParserErrorCode(
      'EXTERNAL_AFTER_CONST',
      "The modifier 'external' should be before the modifier 'const'");

  static const ParserErrorCode EXTERNAL_AFTER_FACTORY = const ParserErrorCode(
      'EXTERNAL_AFTER_FACTORY',
      "The modifier 'external' should be before the modifier 'factory'");

  static const ParserErrorCode EXTERNAL_AFTER_STATIC = const ParserErrorCode(
      'EXTERNAL_AFTER_STATIC',
      "The modifier 'external' should be before the modifier 'static'");

  static const ParserErrorCode EXTERNAL_CLASS = const ParserErrorCode(
      'EXTERNAL_CLASS', "Classes cannot be declared to be 'external'");

  static const ParserErrorCode EXTERNAL_CONSTRUCTOR_WITH_BODY =
      const ParserErrorCode('EXTERNAL_CONSTRUCTOR_WITH_BODY',
          "External constructors cannot have a body");

  static const ParserErrorCode EXTERNAL_ENUM = const ParserErrorCode(
      'EXTERNAL_ENUM', "Enums cannot be declared to be 'external'");

  static const ParserErrorCode EXTERNAL_FIELD = const ParserErrorCode(
      'EXTERNAL_FIELD', "Fields cannot be declared to be 'external'");

  static const ParserErrorCode EXTERNAL_GETTER_WITH_BODY =
      const ParserErrorCode(
          'EXTERNAL_GETTER_WITH_BODY', "External getters cannot have a body");

  static const ParserErrorCode EXTERNAL_METHOD_WITH_BODY =
      const ParserErrorCode(
          'EXTERNAL_METHOD_WITH_BODY', "External methods cannot have a body");

  static const ParserErrorCode EXTERNAL_OPERATOR_WITH_BODY =
      const ParserErrorCode('EXTERNAL_OPERATOR_WITH_BODY',
          "External operators cannot have a body");

  static const ParserErrorCode EXTERNAL_SETTER_WITH_BODY =
      const ParserErrorCode(
          'EXTERNAL_SETTER_WITH_BODY', "External setters cannot have a body");

  static const ParserErrorCode EXTERNAL_TYPEDEF = const ParserErrorCode(
      'EXTERNAL_TYPEDEF', "Type aliases cannot be declared to be 'external'");

  static const ParserErrorCode FACTORY_TOP_LEVEL_DECLARATION =
      const ParserErrorCode('FACTORY_TOP_LEVEL_DECLARATION',
          "Top-level declarations cannot be declared to be 'factory'");

  static const ParserErrorCode FACTORY_WITH_INITIALIZERS =
      const ParserErrorCode('FACTORY_WITH_INITIALIZERS',
          "A 'factory' constructor cannot have initializers",
          "Either remove the 'factory' keyword to make this a generative "
          "constructor or remove the initializers.");

  static const ParserErrorCode FACTORY_WITHOUT_BODY = const ParserErrorCode(
      'FACTORY_WITHOUT_BODY',
      "A non-redirecting 'factory' constructor must have a body");

  static const ParserErrorCode FIELD_INITIALIZER_OUTSIDE_CONSTRUCTOR =
      const ParserErrorCode('FIELD_INITIALIZER_OUTSIDE_CONSTRUCTOR',
          "Field initializers can only be used in a constructor");

  static const ParserErrorCode FINAL_AND_VAR = const ParserErrorCode(
      'FINAL_AND_VAR',
      "Members cannot be declared to be both 'final' and 'var'");

  static const ParserErrorCode FINAL_CLASS = const ParserErrorCode(
      'FINAL_CLASS', "Classes cannot be declared to be 'final'");

  static const ParserErrorCode FINAL_CONSTRUCTOR = const ParserErrorCode(
      'FINAL_CONSTRUCTOR', "A constructor cannot be declared to be 'final'");

  static const ParserErrorCode FINAL_ENUM = const ParserErrorCode(
      'FINAL_ENUM', "Enums cannot be declared to be 'final'");

  static const ParserErrorCode FINAL_METHOD = const ParserErrorCode(
      'FINAL_METHOD',
      "Getters, setters and methods cannot be declared to be 'final'");

  static const ParserErrorCode FINAL_TYPEDEF = const ParserErrorCode(
      'FINAL_TYPEDEF', "Type aliases cannot be declared to be 'final'");

  static const ParserErrorCode FUNCTION_TYPED_PARAMETER_VAR = const ParserErrorCode(
      'FUNCTION_TYPED_PARAMETER_VAR',
      "Function typed parameters cannot specify 'const', 'final' or 'var' instead of return type");

  static const ParserErrorCode GETTER_IN_FUNCTION = const ParserErrorCode(
      'GETTER_IN_FUNCTION',
      "Getters cannot be defined within methods or functions");

  static const ParserErrorCode GETTER_WITH_PARAMETERS = const ParserErrorCode(
      'GETTER_WITH_PARAMETERS',
      "Getter should be declared without a parameter list");

  static const ParserErrorCode ILLEGAL_ASSIGNMENT_TO_NON_ASSIGNABLE =
      const ParserErrorCode('ILLEGAL_ASSIGNMENT_TO_NON_ASSIGNABLE',
          "Illegal assignment to non-assignable expression");

  static const ParserErrorCode IMPLEMENTS_BEFORE_EXTENDS =
      const ParserErrorCode('IMPLEMENTS_BEFORE_EXTENDS',
          "The extends clause must be before the implements clause");

  static const ParserErrorCode IMPLEMENTS_BEFORE_WITH = const ParserErrorCode(
      'IMPLEMENTS_BEFORE_WITH',
      "The with clause must be before the implements clause");

  static const ParserErrorCode IMPORT_DIRECTIVE_AFTER_PART_DIRECTIVE =
      const ParserErrorCode('IMPORT_DIRECTIVE_AFTER_PART_DIRECTIVE',
          "Import directives must preceed part directives");

  static const ParserErrorCode INITIALIZED_VARIABLE_IN_FOR_EACH =
      const ParserErrorCode('INITIALIZED_VARIABLE_IN_FOR_EACH',
          "The loop variable in a for-each loop cannot be initialized");

  static const ParserErrorCode INVALID_AWAIT_IN_FOR = const ParserErrorCode(
      'INVALID_AWAIT_IN_FOR',
      "The modifier 'await' is not allowed for a normal 'for' statement",
      "Remove the keyword or use a for-each statement.");

  static const ParserErrorCode INVALID_CODE_POINT = const ParserErrorCode(
      'INVALID_CODE_POINT',
      "The escape sequence '{0}' is not a valid code point");

  static const ParserErrorCode INVALID_COMMENT_REFERENCE = const ParserErrorCode(
      'INVALID_COMMENT_REFERENCE',
      "Comment references should contain a possibly prefixed identifier and can start with 'new', but should not contain anything else");

  static const ParserErrorCode INVALID_HEX_ESCAPE = const ParserErrorCode(
      'INVALID_HEX_ESCAPE',
      "An escape sequence starting with '\\x' must be followed by 2 hexidecimal digits");

  static const ParserErrorCode INVALID_OPERATOR = const ParserErrorCode(
      'INVALID_OPERATOR', "The string '{0}' is not a valid operator");

  static const ParserErrorCode INVALID_OPERATOR_FOR_SUPER =
      const ParserErrorCode('INVALID_OPERATOR_FOR_SUPER',
          "The operator '{0}' cannot be used with 'super'");

  static const ParserErrorCode INVALID_STAR_AFTER_ASYNC = const ParserErrorCode(
      'INVALID_STAR_AFTER_ASYNC',
      "The modifier 'async*' is not allowed for an expression function body",
      "Convert the body to a block.");

  static const ParserErrorCode INVALID_SYNC = const ParserErrorCode(
      'INVALID_SYNC',
      "The modifier 'sync' is not allowed for an exrpression function body",
      "Convert the body to a block.");

  static const ParserErrorCode INVALID_UNICODE_ESCAPE = const ParserErrorCode(
      'INVALID_UNICODE_ESCAPE',
      "An escape sequence starting with '\\u' must be followed by 4 hexidecimal digits or from 1 to 6 digits between '{' and '}'");

  static const ParserErrorCode LIBRARY_DIRECTIVE_NOT_FIRST =
      const ParserErrorCode('LIBRARY_DIRECTIVE_NOT_FIRST',
          "The library directive must appear before all other directives");

  static const ParserErrorCode LOCAL_FUNCTION_DECLARATION_MODIFIER =
      const ParserErrorCode('LOCAL_FUNCTION_DECLARATION_MODIFIER',
          "Local function declarations cannot specify any modifier");

  static const ParserErrorCode MISSING_ASSIGNABLE_SELECTOR =
      const ParserErrorCode('MISSING_ASSIGNABLE_SELECTOR',
          "Missing selector such as \".<identifier>\" or \"[0]\"");

  static const ParserErrorCode MISSING_ASSIGNMENT_IN_INITIALIZER =
      const ParserErrorCode('MISSING_ASSIGNMENT_IN_INITIALIZER',
          "Expected an assignment after the field name");

  static const ParserErrorCode MISSING_CATCH_OR_FINALLY = const ParserErrorCode(
      'MISSING_CATCH_OR_FINALLY',
      "A try statement must have either a catch or finally clause");

  static const ParserErrorCode MISSING_CLASS_BODY = const ParserErrorCode(
      'MISSING_CLASS_BODY',
      "A class definition must have a body, even if it is empty");

  static const ParserErrorCode MISSING_CLOSING_PARENTHESIS =
      const ParserErrorCode(
          'MISSING_CLOSING_PARENTHESIS', "The closing parenthesis is missing");

  static const ParserErrorCode MISSING_CONST_FINAL_VAR_OR_TYPE =
      const ParserErrorCode('MISSING_CONST_FINAL_VAR_OR_TYPE',
          "Variables must be declared using the keywords 'const', 'final', 'var' or a type name");

  static const ParserErrorCode MISSING_ENUM_BODY = const ParserErrorCode(
      'MISSING_ENUM_BODY',
      "An enum definition must have a body with at least one constant name");

  static const ParserErrorCode MISSING_EXPRESSION_IN_INITIALIZER =
      const ParserErrorCode('MISSING_EXPRESSION_IN_INITIALIZER',
          "Expected an expression after the assignment operator");

  static const ParserErrorCode MISSING_EXPRESSION_IN_THROW =
      const ParserErrorCode('MISSING_EXPRESSION_IN_THROW',
          "Throw expressions must compute the object to be thrown");

  static const ParserErrorCode MISSING_FUNCTION_BODY = const ParserErrorCode(
      'MISSING_FUNCTION_BODY', "A function body must be provided");

  static const ParserErrorCode MISSING_FUNCTION_PARAMETERS =
      const ParserErrorCode('MISSING_FUNCTION_PARAMETERS',
          "Functions must have an explicit list of parameters");

  static const ParserErrorCode MISSING_METHOD_PARAMETERS =
      const ParserErrorCode('MISSING_METHOD_PARAMETERS',
          "Methods must have an explicit list of parameters");

  static const ParserErrorCode MISSING_GET = const ParserErrorCode(
      'MISSING_GET',
      "Getters must have the keyword 'get' before the getter name");

  static const ParserErrorCode MISSING_IDENTIFIER =
      const ParserErrorCode('MISSING_IDENTIFIER', "Expected an identifier");

  static const ParserErrorCode MISSING_INITIALIZER =
      const ParserErrorCode('MISSING_INITIALIZER', "Expected an initializer");

  static const ParserErrorCode MISSING_KEYWORD_OPERATOR = const ParserErrorCode(
      'MISSING_KEYWORD_OPERATOR',
      "Operator declarations must be preceeded by the keyword 'operator'");

  static const ParserErrorCode MISSING_NAME_IN_LIBRARY_DIRECTIVE =
      const ParserErrorCode('MISSING_NAME_IN_LIBRARY_DIRECTIVE',
          "Library directives must include a library name");

  static const ParserErrorCode MISSING_NAME_IN_PART_OF_DIRECTIVE =
      const ParserErrorCode('MISSING_NAME_IN_PART_OF_DIRECTIVE',
          "Library directives must include a library name");

  static const ParserErrorCode MISSING_PREFIX_IN_DEFERRED_IMPORT =
      const ParserErrorCode('MISSING_PREFIX_IN_DEFERRED_IMPORT',
          "Deferred imports must have a prefix");

  static const ParserErrorCode MISSING_STAR_AFTER_SYNC = const ParserErrorCode(
      'MISSING_STAR_AFTER_SYNC',
      "The modifier 'sync' must be followed by a star ('*')",
      "Remove the modifier or add a star.");

  static const ParserErrorCode MISSING_STATEMENT =
      const ParserErrorCode('MISSING_STATEMENT', "Expected a statement");

  static const ParserErrorCode MISSING_TERMINATOR_FOR_PARAMETER_GROUP =
      const ParserErrorCode('MISSING_TERMINATOR_FOR_PARAMETER_GROUP',
          "There is no '{0}' to close the parameter group");

  static const ParserErrorCode MISSING_TYPEDEF_PARAMETERS =
      const ParserErrorCode('MISSING_TYPEDEF_PARAMETERS',
          "Type aliases for functions must have an explicit list of parameters");

  static const ParserErrorCode MISSING_VARIABLE_IN_FOR_EACH = const ParserErrorCode(
      'MISSING_VARIABLE_IN_FOR_EACH',
      "A loop variable must be declared in a for-each loop before the 'in', but none were found");

  static const ParserErrorCode MIXED_PARAMETER_GROUPS = const ParserErrorCode(
      'MIXED_PARAMETER_GROUPS',
      "Cannot have both positional and named parameters in a single parameter list");

  static const ParserErrorCode MULTIPLE_EXTENDS_CLAUSES = const ParserErrorCode(
      'MULTIPLE_EXTENDS_CLAUSES',
      "Each class definition can have at most one extends clause");

  static const ParserErrorCode MULTIPLE_IMPLEMENTS_CLAUSES =
      const ParserErrorCode('MULTIPLE_IMPLEMENTS_CLAUSES',
          "Each class definition can have at most one implements clause");

  static const ParserErrorCode MULTIPLE_LIBRARY_DIRECTIVES =
      const ParserErrorCode('MULTIPLE_LIBRARY_DIRECTIVES',
          "Only one library directive may be declared in a file");

  static const ParserErrorCode MULTIPLE_NAMED_PARAMETER_GROUPS =
      const ParserErrorCode('MULTIPLE_NAMED_PARAMETER_GROUPS',
          "Cannot have multiple groups of named parameters in a single parameter list");

  static const ParserErrorCode MULTIPLE_PART_OF_DIRECTIVES =
      const ParserErrorCode('MULTIPLE_PART_OF_DIRECTIVES',
          "Only one part-of directive may be declared in a file");

  static const ParserErrorCode MULTIPLE_POSITIONAL_PARAMETER_GROUPS =
      const ParserErrorCode('MULTIPLE_POSITIONAL_PARAMETER_GROUPS',
          "Cannot have multiple groups of positional parameters in a single parameter list");

  static const ParserErrorCode MULTIPLE_VARIABLES_IN_FOR_EACH =
      const ParserErrorCode('MULTIPLE_VARIABLES_IN_FOR_EACH',
          "A single loop variable must be declared in a for-each loop before the 'in', but {0} were found");

  static const ParserErrorCode MULTIPLE_WITH_CLAUSES = const ParserErrorCode(
      'MULTIPLE_WITH_CLAUSES',
      "Each class definition can have at most one with clause");

  static const ParserErrorCode NAMED_FUNCTION_EXPRESSION =
      const ParserErrorCode(
          'NAMED_FUNCTION_EXPRESSION', "Function expressions cannot be named");

  static const ParserErrorCode NAMED_PARAMETER_OUTSIDE_GROUP =
      const ParserErrorCode('NAMED_PARAMETER_OUTSIDE_GROUP',
          "Named parameters must be enclosed in curly braces ('{' and '}')");

  static const ParserErrorCode NATIVE_CLAUSE_IN_NON_SDK_CODE =
      const ParserErrorCode('NATIVE_CLAUSE_IN_NON_SDK_CODE',
          "Native clause can only be used in the SDK and code that is loaded through native extensions");

  static const ParserErrorCode NATIVE_FUNCTION_BODY_IN_NON_SDK_CODE =
      const ParserErrorCode('NATIVE_FUNCTION_BODY_IN_NON_SDK_CODE',
          "Native functions can only be declared in the SDK and code that is loaded through native extensions");

  static const ParserErrorCode NON_CONSTRUCTOR_FACTORY = const ParserErrorCode(
      'NON_CONSTRUCTOR_FACTORY',
      "Only constructors can be declared to be a 'factory'");

  static const ParserErrorCode NON_IDENTIFIER_LIBRARY_NAME =
      const ParserErrorCode('NON_IDENTIFIER_LIBRARY_NAME',
          "The name of a library must be an identifier");

  static const ParserErrorCode NON_PART_OF_DIRECTIVE_IN_PART =
      const ParserErrorCode('NON_PART_OF_DIRECTIVE_IN_PART',
          "The part-of directive must be the only directive in a part");

  static const ParserErrorCode NON_STRING_LITERAL_AS_URI =
      const ParserErrorCode('NON_STRING_LITERAL_AS_URI',
          "The URI must be a string literal",
          "Enclose the URI in either single or double quotes.");

  static const ParserErrorCode NON_USER_DEFINABLE_OPERATOR =
      const ParserErrorCode('NON_USER_DEFINABLE_OPERATOR',
          "The operator '{0}' is not user definable");

  static const ParserErrorCode NORMAL_BEFORE_OPTIONAL_PARAMETERS =
      const ParserErrorCode('NORMAL_BEFORE_OPTIONAL_PARAMETERS',
          "Normal parameters must occur before optional parameters");

  static const ParserErrorCode POSITIONAL_AFTER_NAMED_ARGUMENT =
      const ParserErrorCode('POSITIONAL_AFTER_NAMED_ARGUMENT',
          "Positional arguments must occur before named arguments");

  static const ParserErrorCode POSITIONAL_PARAMETER_OUTSIDE_GROUP =
      const ParserErrorCode('POSITIONAL_PARAMETER_OUTSIDE_GROUP',
          "Positional parameters must be enclosed in square brackets ('[' and ']')");

  static const ParserErrorCode REDIRECTION_IN_NON_FACTORY_CONSTRUCTOR =
      const ParserErrorCode('REDIRECTION_IN_NON_FACTORY_CONSTRUCTOR',
          "Only factory constructor can specify '=' redirection.");

  static const ParserErrorCode SETTER_IN_FUNCTION = const ParserErrorCode(
      'SETTER_IN_FUNCTION',
      "Setters cannot be defined within methods or functions");

  static const ParserErrorCode STATIC_AFTER_CONST = const ParserErrorCode(
      'STATIC_AFTER_CONST',
      "The modifier 'static' should be before the modifier 'const'");

  static const ParserErrorCode STATIC_AFTER_FINAL = const ParserErrorCode(
      'STATIC_AFTER_FINAL',
      "The modifier 'static' should be before the modifier 'final'");

  static const ParserErrorCode STATIC_AFTER_VAR = const ParserErrorCode(
      'STATIC_AFTER_VAR',
      "The modifier 'static' should be before the modifier 'var'");

  static const ParserErrorCode STATIC_CONSTRUCTOR = const ParserErrorCode(
      'STATIC_CONSTRUCTOR', "Constructors cannot be static");

  static const ParserErrorCode STATIC_GETTER_WITHOUT_BODY =
      const ParserErrorCode(
          'STATIC_GETTER_WITHOUT_BODY', "A 'static' getter must have a body");

  static const ParserErrorCode STATIC_OPERATOR =
      const ParserErrorCode('STATIC_OPERATOR', "Operators cannot be static");

  static const ParserErrorCode STATIC_SETTER_WITHOUT_BODY =
      const ParserErrorCode(
          'STATIC_SETTER_WITHOUT_BODY', "A 'static' setter must have a body");

  static const ParserErrorCode STATIC_TOP_LEVEL_DECLARATION =
      const ParserErrorCode('STATIC_TOP_LEVEL_DECLARATION',
          "Top-level declarations cannot be declared to be 'static'");

  static const ParserErrorCode SWITCH_HAS_CASE_AFTER_DEFAULT_CASE =
      const ParserErrorCode('SWITCH_HAS_CASE_AFTER_DEFAULT_CASE',
          "The 'default' case should be the last case in a switch statement");

  static const ParserErrorCode SWITCH_HAS_MULTIPLE_DEFAULT_CASES =
      const ParserErrorCode('SWITCH_HAS_MULTIPLE_DEFAULT_CASES',
          "The 'default' case can only be declared once");

  static const ParserErrorCode TOP_LEVEL_OPERATOR = const ParserErrorCode(
      'TOP_LEVEL_OPERATOR', "Operators must be declared within a class");

  static const ParserErrorCode TYPEDEF_IN_CLASS = const ParserErrorCode(
      'TYPEDEF_IN_CLASS',
      "Function type aliases cannot be declared inside classes");

  static const ParserErrorCode UNEXPECTED_TERMINATOR_FOR_PARAMETER_GROUP =
      const ParserErrorCode('UNEXPECTED_TERMINATOR_FOR_PARAMETER_GROUP',
          "There is no '{0}' to open a parameter group");

  static const ParserErrorCode UNEXPECTED_TOKEN =
      const ParserErrorCode('UNEXPECTED_TOKEN', "Unexpected token '{0}'");

  static const ParserErrorCode WITH_BEFORE_EXTENDS = const ParserErrorCode(
      'WITH_BEFORE_EXTENDS',
      "The extends clause must be before the with clause");

  static const ParserErrorCode WITH_WITHOUT_EXTENDS = const ParserErrorCode(
      'WITH_WITHOUT_EXTENDS',
      "The with clause cannot be used without an extends clause");

  static const ParserErrorCode WRONG_SEPARATOR_FOR_NAMED_PARAMETER =
      const ParserErrorCode('WRONG_SEPARATOR_FOR_NAMED_PARAMETER',
          "The default value of a named parameter should be preceeded by ':'");

  static const ParserErrorCode WRONG_SEPARATOR_FOR_POSITIONAL_PARAMETER =
      const ParserErrorCode('WRONG_SEPARATOR_FOR_POSITIONAL_PARAMETER',
          "The default value of a positional parameter should be preceeded by '='");

  static const ParserErrorCode WRONG_TERMINATOR_FOR_PARAMETER_GROUP =
      const ParserErrorCode('WRONG_TERMINATOR_FOR_PARAMETER_GROUP',
          "Expected '{0}' to close parameter group");

  static const ParserErrorCode VAR_AND_TYPE = const ParserErrorCode(
      'VAR_AND_TYPE',
      "Variables cannot be declared using both 'var' and a type name; remove the 'var'");

  static const ParserErrorCode VAR_AS_TYPE_NAME = const ParserErrorCode(
      'VAR_AS_TYPE_NAME', "The keyword 'var' cannot be used as a type name");

  static const ParserErrorCode VAR_CLASS = const ParserErrorCode(
      'VAR_CLASS', "Classes cannot be declared to be 'var'");

  static const ParserErrorCode VAR_ENUM =
      const ParserErrorCode('VAR_ENUM', "Enums cannot be declared to be 'var'");

  static const ParserErrorCode VAR_RETURN_TYPE = const ParserErrorCode(
      'VAR_RETURN_TYPE', "The return type cannot be 'var'");

  static const ParserErrorCode VAR_TYPEDEF = const ParserErrorCode(
      'VAR_TYPEDEF', "Type aliases cannot be declared to be 'var'");

  static const ParserErrorCode VOID_PARAMETER = const ParserErrorCode(
      'VOID_PARAMETER', "Parameters cannot have a type of 'void'");

  static const ParserErrorCode VOID_VARIABLE = const ParserErrorCode(
      'VOID_VARIABLE', "Variables cannot have a type of 'void'");

  /**
   * Initialize a newly created error code to have the given [name]. The message
   * associated with the error will be created from the given [message]
   * template. The correction associated with the error will be created from the
   * given [correction] template.
   */
  const ParserErrorCode(String name, String message, [String correction])
      : super(name, message, correction);

  @override
  ErrorSeverity get errorSeverity => ErrorSeverity.ERROR;

  @override
  ErrorType get type => ErrorType.SYNTACTIC_ERROR;
}

/**
 * An object that copies resolution information from one AST structure to
 * another as long as the structures of the corresponding children of a pair of
 * nodes are the same.
 */
class ResolutionCopier implements AstVisitor<bool> {
  /**
   * The AST node with which the node being visited is to be compared. This is
   * only valid at the beginning of each visit method (until [isEqualNodes] is
   * invoked).
   */
  AstNode _toNode;

  @override
  bool visitAdjacentStrings(AdjacentStrings node) {
    AdjacentStrings toNode = this._toNode as AdjacentStrings;
    return _isEqualNodeLists(node.strings, toNode.strings);
  }

  @override
  bool visitAnnotation(Annotation node) {
    Annotation toNode = this._toNode as Annotation;
    if (_and(_isEqualTokens(node.atSign, toNode.atSign),
        _isEqualNodes(node.name, toNode.name),
        _isEqualTokens(node.period, toNode.period),
        _isEqualNodes(node.constructorName, toNode.constructorName),
        _isEqualNodes(node.arguments, toNode.arguments))) {
      toNode.element = node.element;
      return true;
    }
    return false;
  }

  @override
  bool visitArgumentList(ArgumentList node) {
    ArgumentList toNode = this._toNode as ArgumentList;
    return _and(_isEqualTokens(node.leftParenthesis, toNode.leftParenthesis),
        _isEqualNodeLists(node.arguments, toNode.arguments),
        _isEqualTokens(node.rightParenthesis, toNode.rightParenthesis));
  }

  @override
  bool visitAsExpression(AsExpression node) {
    AsExpression toNode = this._toNode as AsExpression;
    if (_and(_isEqualNodes(node.expression, toNode.expression),
        _isEqualTokens(node.asOperator, toNode.asOperator),
        _isEqualNodes(node.type, toNode.type))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitAssertStatement(AssertStatement node) {
    AssertStatement toNode = this._toNode as AssertStatement;
    return _and(_isEqualTokens(node.assertKeyword, toNode.assertKeyword),
        _isEqualTokens(node.leftParenthesis, toNode.leftParenthesis),
        _isEqualNodes(node.condition, toNode.condition),
        _isEqualTokens(node.rightParenthesis, toNode.rightParenthesis),
        _isEqualTokens(node.semicolon, toNode.semicolon));
  }

  @override
  bool visitAssignmentExpression(AssignmentExpression node) {
    AssignmentExpression toNode = this._toNode as AssignmentExpression;
    if (_and(_isEqualNodes(node.leftHandSide, toNode.leftHandSide),
        _isEqualTokens(node.operator, toNode.operator),
        _isEqualNodes(node.rightHandSide, toNode.rightHandSide))) {
      toNode.propagatedElement = node.propagatedElement;
      toNode.propagatedType = node.propagatedType;
      toNode.staticElement = node.staticElement;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitAwaitExpression(AwaitExpression node) {
    AwaitExpression toNode = this._toNode as AwaitExpression;
    if (_and(_isEqualTokens(node.awaitKeyword, toNode.awaitKeyword),
        _isEqualNodes(node.expression, toNode.expression))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitBinaryExpression(BinaryExpression node) {
    BinaryExpression toNode = this._toNode as BinaryExpression;
    if (_and(_isEqualNodes(node.leftOperand, toNode.leftOperand),
        _isEqualTokens(node.operator, toNode.operator),
        _isEqualNodes(node.rightOperand, toNode.rightOperand))) {
      toNode.propagatedElement = node.propagatedElement;
      toNode.propagatedType = node.propagatedType;
      toNode.staticElement = node.staticElement;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitBlock(Block node) {
    Block toNode = this._toNode as Block;
    return _and(_isEqualTokens(node.leftBracket, toNode.leftBracket),
        _isEqualNodeLists(node.statements, toNode.statements),
        _isEqualTokens(node.rightBracket, toNode.rightBracket));
  }

  @override
  bool visitBlockFunctionBody(BlockFunctionBody node) {
    BlockFunctionBody toNode = this._toNode as BlockFunctionBody;
    return _isEqualNodes(node.block, toNode.block);
  }

  @override
  bool visitBooleanLiteral(BooleanLiteral node) {
    BooleanLiteral toNode = this._toNode as BooleanLiteral;
    if (_and(_isEqualTokens(node.literal, toNode.literal),
        node.value == toNode.value)) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitBreakStatement(BreakStatement node) {
    BreakStatement toNode = this._toNode as BreakStatement;
    if (_and(_isEqualTokens(node.breakKeyword, toNode.breakKeyword),
        _isEqualNodes(node.label, toNode.label),
        _isEqualTokens(node.semicolon, toNode.semicolon))) {
      // TODO(paulberry): map node.target to toNode.target.
      return true;
    }
    return false;
  }

  @override
  bool visitCascadeExpression(CascadeExpression node) {
    CascadeExpression toNode = this._toNode as CascadeExpression;
    if (_and(_isEqualNodes(node.target, toNode.target),
        _isEqualNodeLists(node.cascadeSections, toNode.cascadeSections))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitCatchClause(CatchClause node) {
    CatchClause toNode = this._toNode as CatchClause;
    return _and(_isEqualTokens(node.onKeyword, toNode.onKeyword),
        _isEqualNodes(node.exceptionType, toNode.exceptionType),
        _isEqualTokens(node.catchKeyword, toNode.catchKeyword),
        _isEqualTokens(node.leftParenthesis, toNode.leftParenthesis),
        _isEqualNodes(node.exceptionParameter, toNode.exceptionParameter),
        _isEqualTokens(node.comma, toNode.comma),
        _isEqualNodes(node.stackTraceParameter, toNode.stackTraceParameter),
        _isEqualTokens(node.rightParenthesis, toNode.rightParenthesis),
        _isEqualNodes(node.body, toNode.body));
  }

  @override
  bool visitClassDeclaration(ClassDeclaration node) {
    ClassDeclaration toNode = this._toNode as ClassDeclaration;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.abstractKeyword, toNode.abstractKeyword),
        _isEqualTokens(node.classKeyword, toNode.classKeyword),
        _isEqualNodes(node.name, toNode.name),
        _isEqualNodes(node.typeParameters, toNode.typeParameters),
        _isEqualNodes(node.extendsClause, toNode.extendsClause),
        _isEqualNodes(node.withClause, toNode.withClause),
        _isEqualNodes(node.implementsClause, toNode.implementsClause),
        _isEqualTokens(node.leftBracket, toNode.leftBracket),
        _isEqualNodeLists(node.members, toNode.members),
        _isEqualTokens(node.rightBracket, toNode.rightBracket));
  }

  @override
  bool visitClassTypeAlias(ClassTypeAlias node) {
    ClassTypeAlias toNode = this._toNode as ClassTypeAlias;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.typedefKeyword, toNode.typedefKeyword),
        _isEqualNodes(node.name, toNode.name),
        _isEqualNodes(node.typeParameters, toNode.typeParameters),
        _isEqualTokens(node.equals, toNode.equals),
        _isEqualTokens(node.abstractKeyword, toNode.abstractKeyword),
        _isEqualNodes(node.superclass, toNode.superclass),
        _isEqualNodes(node.withClause, toNode.withClause),
        _isEqualNodes(node.implementsClause, toNode.implementsClause),
        _isEqualTokens(node.semicolon, toNode.semicolon));
  }

  @override
  bool visitComment(Comment node) {
    Comment toNode = this._toNode as Comment;
    return _isEqualNodeLists(node.references, toNode.references);
  }

  @override
  bool visitCommentReference(CommentReference node) {
    CommentReference toNode = this._toNode as CommentReference;
    return _and(_isEqualTokens(node.newKeyword, toNode.newKeyword),
        _isEqualNodes(node.identifier, toNode.identifier));
  }

  @override
  bool visitCompilationUnit(CompilationUnit node) {
    CompilationUnit toNode = this._toNode as CompilationUnit;
    if (_and(_isEqualTokens(node.beginToken, toNode.beginToken),
        _isEqualNodes(node.scriptTag, toNode.scriptTag),
        _isEqualNodeLists(node.directives, toNode.directives),
        _isEqualNodeLists(node.declarations, toNode.declarations),
        _isEqualTokens(node.endToken, toNode.endToken))) {
      toNode.element = node.element;
      return true;
    }
    return false;
  }

  @override
  bool visitConditionalExpression(ConditionalExpression node) {
    ConditionalExpression toNode = this._toNode as ConditionalExpression;
    if (_and(_isEqualNodes(node.condition, toNode.condition),
        _isEqualTokens(node.question, toNode.question),
        _isEqualNodes(node.thenExpression, toNode.thenExpression),
        _isEqualTokens(node.colon, toNode.colon),
        _isEqualNodes(node.elseExpression, toNode.elseExpression))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitConstructorDeclaration(ConstructorDeclaration node) {
    ConstructorDeclaration toNode = this._toNode as ConstructorDeclaration;
    if (_and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.externalKeyword, toNode.externalKeyword),
        _isEqualTokens(node.constKeyword, toNode.constKeyword),
        _isEqualTokens(node.factoryKeyword, toNode.factoryKeyword),
        _isEqualNodes(node.returnType, toNode.returnType),
        _isEqualTokens(node.period, toNode.period),
        _isEqualNodes(node.name, toNode.name),
        _isEqualNodes(node.parameters, toNode.parameters),
        _isEqualTokens(node.separator, toNode.separator),
        _isEqualNodeLists(node.initializers, toNode.initializers),
        _isEqualNodes(node.redirectedConstructor, toNode.redirectedConstructor),
        _isEqualNodes(node.body, toNode.body))) {
      toNode.element = node.element;
      return true;
    }
    return false;
  }

  @override
  bool visitConstructorFieldInitializer(ConstructorFieldInitializer node) {
    ConstructorFieldInitializer toNode =
        this._toNode as ConstructorFieldInitializer;
    return _and(_isEqualTokens(node.thisKeyword, toNode.thisKeyword),
        _isEqualTokens(node.period, toNode.period),
        _isEqualNodes(node.fieldName, toNode.fieldName),
        _isEqualTokens(node.equals, toNode.equals),
        _isEqualNodes(node.expression, toNode.expression));
  }

  @override
  bool visitConstructorName(ConstructorName node) {
    ConstructorName toNode = this._toNode as ConstructorName;
    if (_and(_isEqualNodes(node.type, toNode.type),
        _isEqualTokens(node.period, toNode.period),
        _isEqualNodes(node.name, toNode.name))) {
      toNode.staticElement = node.staticElement;
      return true;
    }
    return false;
  }

  @override
  bool visitContinueStatement(ContinueStatement node) {
    ContinueStatement toNode = this._toNode as ContinueStatement;
    if (_and(_isEqualTokens(node.continueKeyword, toNode.continueKeyword),
        _isEqualNodes(node.label, toNode.label),
        _isEqualTokens(node.semicolon, toNode.semicolon))) {
      // TODO(paulberry): map node.target to toNode.target.
      return true;
    }
    return false;
  }

  @override
  bool visitDeclaredIdentifier(DeclaredIdentifier node) {
    DeclaredIdentifier toNode = this._toNode as DeclaredIdentifier;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.keyword, toNode.keyword),
        _isEqualNodes(node.type, toNode.type),
        _isEqualNodes(node.identifier, toNode.identifier));
  }

  @override
  bool visitDefaultFormalParameter(DefaultFormalParameter node) {
    DefaultFormalParameter toNode = this._toNode as DefaultFormalParameter;
    return _and(_isEqualNodes(node.parameter, toNode.parameter),
        node.kind == toNode.kind,
        _isEqualTokens(node.separator, toNode.separator),
        _isEqualNodes(node.defaultValue, toNode.defaultValue));
  }

  @override
  bool visitDoStatement(DoStatement node) {
    DoStatement toNode = this._toNode as DoStatement;
    return _and(_isEqualTokens(node.doKeyword, toNode.doKeyword),
        _isEqualNodes(node.body, toNode.body),
        _isEqualTokens(node.whileKeyword, toNode.whileKeyword),
        _isEqualTokens(node.leftParenthesis, toNode.leftParenthesis),
        _isEqualNodes(node.condition, toNode.condition),
        _isEqualTokens(node.rightParenthesis, toNode.rightParenthesis),
        _isEqualTokens(node.semicolon, toNode.semicolon));
  }

  @override
  bool visitDoubleLiteral(DoubleLiteral node) {
    DoubleLiteral toNode = this._toNode as DoubleLiteral;
    if (_and(_isEqualTokens(node.literal, toNode.literal),
        node.value == toNode.value)) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitEmptyFunctionBody(EmptyFunctionBody node) {
    EmptyFunctionBody toNode = this._toNode as EmptyFunctionBody;
    return _isEqualTokens(node.semicolon, toNode.semicolon);
  }

  @override
  bool visitEmptyStatement(EmptyStatement node) {
    EmptyStatement toNode = this._toNode as EmptyStatement;
    return _isEqualTokens(node.semicolon, toNode.semicolon);
  }

  @override
  bool visitEnumConstantDeclaration(EnumConstantDeclaration node) {
    EnumConstantDeclaration toNode = this._toNode as EnumConstantDeclaration;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualNodes(node.name, toNode.name));
  }

  @override
  bool visitEnumDeclaration(EnumDeclaration node) {
    EnumDeclaration toNode = this._toNode as EnumDeclaration;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.enumKeyword, toNode.enumKeyword),
        _isEqualNodes(node.name, toNode.name),
        _isEqualTokens(node.leftBracket, toNode.leftBracket),
        _isEqualNodeLists(node.constants, toNode.constants),
        _isEqualTokens(node.rightBracket, toNode.rightBracket));
  }

  @override
  bool visitExportDirective(ExportDirective node) {
    ExportDirective toNode = this._toNode as ExportDirective;
    if (_and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.keyword, toNode.keyword),
        _isEqualNodes(node.uri, toNode.uri),
        _isEqualNodeLists(node.combinators, toNode.combinators),
        _isEqualTokens(node.semicolon, toNode.semicolon))) {
      toNode.element = node.element;
      return true;
    }
    return false;
  }

  @override
  bool visitExpressionFunctionBody(ExpressionFunctionBody node) {
    ExpressionFunctionBody toNode = this._toNode as ExpressionFunctionBody;
    return _and(
        _isEqualTokens(node.functionDefinition, toNode.functionDefinition),
        _isEqualNodes(node.expression, toNode.expression),
        _isEqualTokens(node.semicolon, toNode.semicolon));
  }

  @override
  bool visitExpressionStatement(ExpressionStatement node) {
    ExpressionStatement toNode = this._toNode as ExpressionStatement;
    return _and(_isEqualNodes(node.expression, toNode.expression),
        _isEqualTokens(node.semicolon, toNode.semicolon));
  }

  @override
  bool visitExtendsClause(ExtendsClause node) {
    ExtendsClause toNode = this._toNode as ExtendsClause;
    return _and(_isEqualTokens(node.extendsKeyword, toNode.extendsKeyword),
        _isEqualNodes(node.superclass, toNode.superclass));
  }

  @override
  bool visitFieldDeclaration(FieldDeclaration node) {
    FieldDeclaration toNode = this._toNode as FieldDeclaration;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.staticKeyword, toNode.staticKeyword),
        _isEqualNodes(node.fields, toNode.fields),
        _isEqualTokens(node.semicolon, toNode.semicolon));
  }

  @override
  bool visitFieldFormalParameter(FieldFormalParameter node) {
    FieldFormalParameter toNode = this._toNode as FieldFormalParameter;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.keyword, toNode.keyword),
        _isEqualNodes(node.type, toNode.type),
        _isEqualTokens(node.thisKeyword, toNode.thisKeyword),
        _isEqualTokens(node.period, toNode.period),
        _isEqualNodes(node.identifier, toNode.identifier));
  }

  @override
  bool visitForEachStatement(ForEachStatement node) {
    ForEachStatement toNode = this._toNode as ForEachStatement;
    return _and(_isEqualTokens(node.forKeyword, toNode.forKeyword),
        _isEqualTokens(node.leftParenthesis, toNode.leftParenthesis),
        _isEqualNodes(node.loopVariable, toNode.loopVariable),
        _isEqualTokens(node.inKeyword, toNode.inKeyword),
        _isEqualNodes(node.iterable, toNode.iterable),
        _isEqualTokens(node.rightParenthesis, toNode.rightParenthesis),
        _isEqualNodes(node.body, toNode.body));
  }

  @override
  bool visitFormalParameterList(FormalParameterList node) {
    FormalParameterList toNode = this._toNode as FormalParameterList;
    return _and(_isEqualTokens(node.leftParenthesis, toNode.leftParenthesis),
        _isEqualNodeLists(node.parameters, toNode.parameters),
        _isEqualTokens(node.leftDelimiter, toNode.leftDelimiter),
        _isEqualTokens(node.rightDelimiter, toNode.rightDelimiter),
        _isEqualTokens(node.rightParenthesis, toNode.rightParenthesis));
  }

  @override
  bool visitForStatement(ForStatement node) {
    ForStatement toNode = this._toNode as ForStatement;
    return _and(_isEqualTokens(node.forKeyword, toNode.forKeyword),
        _isEqualTokens(node.leftParenthesis, toNode.leftParenthesis),
        _isEqualNodes(node.variables, toNode.variables),
        _isEqualNodes(node.initialization, toNode.initialization),
        _isEqualTokens(node.leftSeparator, toNode.leftSeparator),
        _isEqualNodes(node.condition, toNode.condition),
        _isEqualTokens(node.rightSeparator, toNode.rightSeparator),
        _isEqualNodeLists(node.updaters, toNode.updaters),
        _isEqualTokens(node.rightParenthesis, toNode.rightParenthesis),
        _isEqualNodes(node.body, toNode.body));
  }

  @override
  bool visitFunctionDeclaration(FunctionDeclaration node) {
    FunctionDeclaration toNode = this._toNode as FunctionDeclaration;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.externalKeyword, toNode.externalKeyword),
        _isEqualNodes(node.returnType, toNode.returnType),
        _isEqualTokens(node.propertyKeyword, toNode.propertyKeyword),
        _isEqualNodes(node.name, toNode.name),
        _isEqualNodes(node.functionExpression, toNode.functionExpression));
  }

  @override
  bool visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    FunctionDeclarationStatement toNode =
        this._toNode as FunctionDeclarationStatement;
    return _isEqualNodes(node.functionDeclaration, toNode.functionDeclaration);
  }

  @override
  bool visitFunctionExpression(FunctionExpression node) {
    FunctionExpression toNode = this._toNode as FunctionExpression;
    if (_and(_isEqualNodes(node.parameters, toNode.parameters),
        _isEqualNodes(node.body, toNode.body))) {
      toNode.element = node.element;
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    FunctionExpressionInvocation toNode =
        this._toNode as FunctionExpressionInvocation;
    if (_and(_isEqualNodes(node.function, toNode.function),
        _isEqualNodes(node.argumentList, toNode.argumentList))) {
      toNode.propagatedElement = node.propagatedElement;
      toNode.propagatedType = node.propagatedType;
      toNode.staticElement = node.staticElement;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitFunctionTypeAlias(FunctionTypeAlias node) {
    FunctionTypeAlias toNode = this._toNode as FunctionTypeAlias;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.typedefKeyword, toNode.typedefKeyword),
        _isEqualNodes(node.returnType, toNode.returnType),
        _isEqualNodes(node.name, toNode.name),
        _isEqualNodes(node.typeParameters, toNode.typeParameters),
        _isEqualNodes(node.parameters, toNode.parameters),
        _isEqualTokens(node.semicolon, toNode.semicolon));
  }

  @override
  bool visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    FunctionTypedFormalParameter toNode =
        this._toNode as FunctionTypedFormalParameter;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualNodes(node.returnType, toNode.returnType),
        _isEqualNodes(node.identifier, toNode.identifier),
        _isEqualNodes(node.parameters, toNode.parameters));
  }

  @override
  bool visitHideCombinator(HideCombinator node) {
    HideCombinator toNode = this._toNode as HideCombinator;
    return _and(_isEqualTokens(node.keyword, toNode.keyword),
        _isEqualNodeLists(node.hiddenNames, toNode.hiddenNames));
  }

  @override
  bool visitIfStatement(IfStatement node) {
    IfStatement toNode = this._toNode as IfStatement;
    return _and(_isEqualTokens(node.ifKeyword, toNode.ifKeyword),
        _isEqualTokens(node.leftParenthesis, toNode.leftParenthesis),
        _isEqualNodes(node.condition, toNode.condition),
        _isEqualTokens(node.rightParenthesis, toNode.rightParenthesis),
        _isEqualNodes(node.thenStatement, toNode.thenStatement),
        _isEqualTokens(node.elseKeyword, toNode.elseKeyword),
        _isEqualNodes(node.elseStatement, toNode.elseStatement));
  }

  @override
  bool visitImplementsClause(ImplementsClause node) {
    ImplementsClause toNode = this._toNode as ImplementsClause;
    return _and(
        _isEqualTokens(node.implementsKeyword, toNode.implementsKeyword),
        _isEqualNodeLists(node.interfaces, toNode.interfaces));
  }

  @override
  bool visitImportDirective(ImportDirective node) {
    ImportDirective toNode = this._toNode as ImportDirective;
    if (_and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.keyword, toNode.keyword),
        _isEqualNodes(node.uri, toNode.uri),
        _isEqualTokens(node.asKeyword, toNode.asKeyword),
        _isEqualNodes(node.prefix, toNode.prefix),
        _isEqualNodeLists(node.combinators, toNode.combinators),
        _isEqualTokens(node.semicolon, toNode.semicolon))) {
      toNode.element = node.element;
      return true;
    }
    return false;
  }

  @override
  bool visitIndexExpression(IndexExpression node) {
    IndexExpression toNode = this._toNode as IndexExpression;
    if (_and(_isEqualNodes(node.target, toNode.target),
        _isEqualTokens(node.leftBracket, toNode.leftBracket),
        _isEqualNodes(node.index, toNode.index),
        _isEqualTokens(node.rightBracket, toNode.rightBracket))) {
      toNode.auxiliaryElements = node.auxiliaryElements;
      toNode.propagatedElement = node.propagatedElement;
      toNode.propagatedType = node.propagatedType;
      toNode.staticElement = node.staticElement;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitInstanceCreationExpression(InstanceCreationExpression node) {
    InstanceCreationExpression toNode =
        this._toNode as InstanceCreationExpression;
    if (_and(_isEqualTokens(node.keyword, toNode.keyword),
        _isEqualNodes(node.constructorName, toNode.constructorName),
        _isEqualNodes(node.argumentList, toNode.argumentList))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticElement = node.staticElement;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitIntegerLiteral(IntegerLiteral node) {
    IntegerLiteral toNode = this._toNode as IntegerLiteral;
    if (_and(_isEqualTokens(node.literal, toNode.literal),
        node.value == toNode.value)) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitInterpolationExpression(InterpolationExpression node) {
    InterpolationExpression toNode = this._toNode as InterpolationExpression;
    return _and(_isEqualTokens(node.leftBracket, toNode.leftBracket),
        _isEqualNodes(node.expression, toNode.expression),
        _isEqualTokens(node.rightBracket, toNode.rightBracket));
  }

  @override
  bool visitInterpolationString(InterpolationString node) {
    InterpolationString toNode = this._toNode as InterpolationString;
    return _and(_isEqualTokens(node.contents, toNode.contents),
        node.value == toNode.value);
  }

  @override
  bool visitIsExpression(IsExpression node) {
    IsExpression toNode = this._toNode as IsExpression;
    if (_and(_isEqualNodes(node.expression, toNode.expression),
        _isEqualTokens(node.isOperator, toNode.isOperator),
        _isEqualTokens(node.notOperator, toNode.notOperator),
        _isEqualNodes(node.type, toNode.type))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitLabel(Label node) {
    Label toNode = this._toNode as Label;
    return _and(_isEqualNodes(node.label, toNode.label),
        _isEqualTokens(node.colon, toNode.colon));
  }

  @override
  bool visitLabeledStatement(LabeledStatement node) {
    LabeledStatement toNode = this._toNode as LabeledStatement;
    return _and(_isEqualNodeLists(node.labels, toNode.labels),
        _isEqualNodes(node.statement, toNode.statement));
  }

  @override
  bool visitLibraryDirective(LibraryDirective node) {
    LibraryDirective toNode = this._toNode as LibraryDirective;
    if (_and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.libraryKeyword, toNode.libraryKeyword),
        _isEqualNodes(node.name, toNode.name),
        _isEqualTokens(node.semicolon, toNode.semicolon))) {
      toNode.element = node.element;
      return true;
    }
    return false;
  }

  @override
  bool visitLibraryIdentifier(LibraryIdentifier node) {
    LibraryIdentifier toNode = this._toNode as LibraryIdentifier;
    if (_isEqualNodeLists(node.components, toNode.components)) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitListLiteral(ListLiteral node) {
    ListLiteral toNode = this._toNode as ListLiteral;
    if (_and(_isEqualTokens(node.constKeyword, toNode.constKeyword),
        _isEqualNodes(node.typeArguments, toNode.typeArguments),
        _isEqualTokens(node.leftBracket, toNode.leftBracket),
        _isEqualNodeLists(node.elements, toNode.elements),
        _isEqualTokens(node.rightBracket, toNode.rightBracket))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitMapLiteral(MapLiteral node) {
    MapLiteral toNode = this._toNode as MapLiteral;
    if (_and(_isEqualTokens(node.constKeyword, toNode.constKeyword),
        _isEqualNodes(node.typeArguments, toNode.typeArguments),
        _isEqualTokens(node.leftBracket, toNode.leftBracket),
        _isEqualNodeLists(node.entries, toNode.entries),
        _isEqualTokens(node.rightBracket, toNode.rightBracket))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitMapLiteralEntry(MapLiteralEntry node) {
    MapLiteralEntry toNode = this._toNode as MapLiteralEntry;
    return _and(_isEqualNodes(node.key, toNode.key),
        _isEqualTokens(node.separator, toNode.separator),
        _isEqualNodes(node.value, toNode.value));
  }

  @override
  bool visitMethodDeclaration(MethodDeclaration node) {
    MethodDeclaration toNode = this._toNode as MethodDeclaration;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.externalKeyword, toNode.externalKeyword),
        _isEqualTokens(node.modifierKeyword, toNode.modifierKeyword),
        _isEqualNodes(node.returnType, toNode.returnType),
        _isEqualTokens(node.propertyKeyword, toNode.propertyKeyword),
        _isEqualTokens(node.propertyKeyword, toNode.propertyKeyword),
        _isEqualNodes(node.name, toNode.name),
        _isEqualNodes(node.parameters, toNode.parameters),
        _isEqualNodes(node.body, toNode.body));
  }

  @override
  bool visitMethodInvocation(MethodInvocation node) {
    MethodInvocation toNode = this._toNode as MethodInvocation;
    if (_and(_isEqualNodes(node.target, toNode.target),
        _isEqualTokens(node.operator, toNode.operator),
        _isEqualNodes(node.methodName, toNode.methodName),
        _isEqualNodes(node.argumentList, toNode.argumentList))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitNamedExpression(NamedExpression node) {
    NamedExpression toNode = this._toNode as NamedExpression;
    if (_and(_isEqualNodes(node.name, toNode.name),
        _isEqualNodes(node.expression, toNode.expression))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitNativeClause(NativeClause node) {
    NativeClause toNode = this._toNode as NativeClause;
    return _and(_isEqualTokens(node.nativeKeyword, toNode.nativeKeyword),
        _isEqualNodes(node.name, toNode.name));
  }

  @override
  bool visitNativeFunctionBody(NativeFunctionBody node) {
    NativeFunctionBody toNode = this._toNode as NativeFunctionBody;
    return _and(_isEqualTokens(node.nativeKeyword, toNode.nativeKeyword),
        _isEqualNodes(node.stringLiteral, toNode.stringLiteral),
        _isEqualTokens(node.semicolon, toNode.semicolon));
  }

  @override
  bool visitNullLiteral(NullLiteral node) {
    NullLiteral toNode = this._toNode as NullLiteral;
    if (_isEqualTokens(node.literal, toNode.literal)) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitParenthesizedExpression(ParenthesizedExpression node) {
    ParenthesizedExpression toNode = this._toNode as ParenthesizedExpression;
    if (_and(_isEqualTokens(node.leftParenthesis, toNode.leftParenthesis),
        _isEqualNodes(node.expression, toNode.expression),
        _isEqualTokens(node.rightParenthesis, toNode.rightParenthesis))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitPartDirective(PartDirective node) {
    PartDirective toNode = this._toNode as PartDirective;
    if (_and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.partKeyword, toNode.partKeyword),
        _isEqualNodes(node.uri, toNode.uri),
        _isEqualTokens(node.semicolon, toNode.semicolon))) {
      toNode.element = node.element;
      return true;
    }
    return false;
  }

  @override
  bool visitPartOfDirective(PartOfDirective node) {
    PartOfDirective toNode = this._toNode as PartOfDirective;
    if (_and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.partKeyword, toNode.partKeyword),
        _isEqualTokens(node.ofKeyword, toNode.ofKeyword),
        _isEqualNodes(node.libraryName, toNode.libraryName),
        _isEqualTokens(node.semicolon, toNode.semicolon))) {
      toNode.element = node.element;
      return true;
    }
    return false;
  }

  @override
  bool visitPostfixExpression(PostfixExpression node) {
    PostfixExpression toNode = this._toNode as PostfixExpression;
    if (_and(_isEqualNodes(node.operand, toNode.operand),
        _isEqualTokens(node.operator, toNode.operator))) {
      toNode.propagatedElement = node.propagatedElement;
      toNode.propagatedType = node.propagatedType;
      toNode.staticElement = node.staticElement;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitPrefixedIdentifier(PrefixedIdentifier node) {
    PrefixedIdentifier toNode = this._toNode as PrefixedIdentifier;
    if (_and(_isEqualNodes(node.prefix, toNode.prefix),
        _isEqualTokens(node.period, toNode.period),
        _isEqualNodes(node.identifier, toNode.identifier))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitPrefixExpression(PrefixExpression node) {
    PrefixExpression toNode = this._toNode as PrefixExpression;
    if (_and(_isEqualTokens(node.operator, toNode.operator),
        _isEqualNodes(node.operand, toNode.operand))) {
      toNode.propagatedElement = node.propagatedElement;
      toNode.propagatedType = node.propagatedType;
      toNode.staticElement = node.staticElement;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitPropertyAccess(PropertyAccess node) {
    PropertyAccess toNode = this._toNode as PropertyAccess;
    if (_and(_isEqualNodes(node.target, toNode.target),
        _isEqualTokens(node.operator, toNode.operator),
        _isEqualNodes(node.propertyName, toNode.propertyName))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitRedirectingConstructorInvocation(
      RedirectingConstructorInvocation node) {
    RedirectingConstructorInvocation toNode =
        this._toNode as RedirectingConstructorInvocation;
    if (_and(_isEqualTokens(node.thisKeyword, toNode.thisKeyword),
        _isEqualTokens(node.period, toNode.period),
        _isEqualNodes(node.constructorName, toNode.constructorName),
        _isEqualNodes(node.argumentList, toNode.argumentList))) {
      toNode.staticElement = node.staticElement;
      return true;
    }
    return false;
  }

  @override
  bool visitRethrowExpression(RethrowExpression node) {
    RethrowExpression toNode = this._toNode as RethrowExpression;
    if (_isEqualTokens(node.rethrowKeyword, toNode.rethrowKeyword)) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitReturnStatement(ReturnStatement node) {
    ReturnStatement toNode = this._toNode as ReturnStatement;
    return _and(_isEqualTokens(node.returnKeyword, toNode.returnKeyword),
        _isEqualNodes(node.expression, toNode.expression),
        _isEqualTokens(node.semicolon, toNode.semicolon));
  }

  @override
  bool visitScriptTag(ScriptTag node) {
    ScriptTag toNode = this._toNode as ScriptTag;
    return _isEqualTokens(node.scriptTag, toNode.scriptTag);
  }

  @override
  bool visitShowCombinator(ShowCombinator node) {
    ShowCombinator toNode = this._toNode as ShowCombinator;
    return _and(_isEqualTokens(node.keyword, toNode.keyword),
        _isEqualNodeLists(node.shownNames, toNode.shownNames));
  }

  @override
  bool visitSimpleFormalParameter(SimpleFormalParameter node) {
    SimpleFormalParameter toNode = this._toNode as SimpleFormalParameter;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.keyword, toNode.keyword),
        _isEqualNodes(node.type, toNode.type),
        _isEqualNodes(node.identifier, toNode.identifier));
  }

  @override
  bool visitSimpleIdentifier(SimpleIdentifier node) {
    SimpleIdentifier toNode = this._toNode as SimpleIdentifier;
    if (_isEqualTokens(node.token, toNode.token)) {
      toNode.staticElement = node.staticElement;
      toNode.staticType = node.staticType;
      toNode.propagatedElement = node.propagatedElement;
      toNode.propagatedType = node.propagatedType;
      toNode.auxiliaryElements = node.auxiliaryElements;
      return true;
    }
    return false;
  }

  @override
  bool visitSimpleStringLiteral(SimpleStringLiteral node) {
    SimpleStringLiteral toNode = this._toNode as SimpleStringLiteral;
    if (_and(_isEqualTokens(node.literal, toNode.literal),
        node.value == toNode.value)) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitStringInterpolation(StringInterpolation node) {
    StringInterpolation toNode = this._toNode as StringInterpolation;
    if (_isEqualNodeLists(node.elements, toNode.elements)) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitSuperConstructorInvocation(SuperConstructorInvocation node) {
    SuperConstructorInvocation toNode =
        this._toNode as SuperConstructorInvocation;
    if (_and(_isEqualTokens(node.superKeyword, toNode.superKeyword),
        _isEqualTokens(node.period, toNode.period),
        _isEqualNodes(node.constructorName, toNode.constructorName),
        _isEqualNodes(node.argumentList, toNode.argumentList))) {
      toNode.staticElement = node.staticElement;
      return true;
    }
    return false;
  }

  @override
  bool visitSuperExpression(SuperExpression node) {
    SuperExpression toNode = this._toNode as SuperExpression;
    if (_isEqualTokens(node.superKeyword, toNode.superKeyword)) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitSwitchCase(SwitchCase node) {
    SwitchCase toNode = this._toNode as SwitchCase;
    return _and(_isEqualNodeLists(node.labels, toNode.labels),
        _isEqualTokens(node.keyword, toNode.keyword),
        _isEqualNodes(node.expression, toNode.expression),
        _isEqualTokens(node.colon, toNode.colon),
        _isEqualNodeLists(node.statements, toNode.statements));
  }

  @override
  bool visitSwitchDefault(SwitchDefault node) {
    SwitchDefault toNode = this._toNode as SwitchDefault;
    return _and(_isEqualNodeLists(node.labels, toNode.labels),
        _isEqualTokens(node.keyword, toNode.keyword),
        _isEqualTokens(node.colon, toNode.colon),
        _isEqualNodeLists(node.statements, toNode.statements));
  }

  @override
  bool visitSwitchStatement(SwitchStatement node) {
    SwitchStatement toNode = this._toNode as SwitchStatement;
    return _and(_isEqualTokens(node.switchKeyword, toNode.switchKeyword),
        _isEqualTokens(node.leftParenthesis, toNode.leftParenthesis),
        _isEqualNodes(node.expression, toNode.expression),
        _isEqualTokens(node.rightParenthesis, toNode.rightParenthesis),
        _isEqualTokens(node.leftBracket, toNode.leftBracket),
        _isEqualNodeLists(node.members, toNode.members),
        _isEqualTokens(node.rightBracket, toNode.rightBracket));
  }

  @override
  bool visitSymbolLiteral(SymbolLiteral node) {
    SymbolLiteral toNode = this._toNode as SymbolLiteral;
    if (_and(_isEqualTokens(node.poundSign, toNode.poundSign),
        _isEqualTokenLists(node.components, toNode.components))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitThisExpression(ThisExpression node) {
    ThisExpression toNode = this._toNode as ThisExpression;
    if (_isEqualTokens(node.thisKeyword, toNode.thisKeyword)) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitThrowExpression(ThrowExpression node) {
    ThrowExpression toNode = this._toNode as ThrowExpression;
    if (_and(_isEqualTokens(node.throwKeyword, toNode.throwKeyword),
        _isEqualNodes(node.expression, toNode.expression))) {
      toNode.propagatedType = node.propagatedType;
      toNode.staticType = node.staticType;
      return true;
    }
    return false;
  }

  @override
  bool visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    TopLevelVariableDeclaration toNode =
        this._toNode as TopLevelVariableDeclaration;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualNodes(node.variables, toNode.variables),
        _isEqualTokens(node.semicolon, toNode.semicolon));
  }

  @override
  bool visitTryStatement(TryStatement node) {
    TryStatement toNode = this._toNode as TryStatement;
    return _and(_isEqualTokens(node.tryKeyword, toNode.tryKeyword),
        _isEqualNodes(node.body, toNode.body),
        _isEqualNodeLists(node.catchClauses, toNode.catchClauses),
        _isEqualTokens(node.finallyKeyword, toNode.finallyKeyword),
        _isEqualNodes(node.finallyBlock, toNode.finallyBlock));
  }

  @override
  bool visitTypeArgumentList(TypeArgumentList node) {
    TypeArgumentList toNode = this._toNode as TypeArgumentList;
    return _and(_isEqualTokens(node.leftBracket, toNode.leftBracket),
        _isEqualNodeLists(node.arguments, toNode.arguments),
        _isEqualTokens(node.rightBracket, toNode.rightBracket));
  }

  @override
  bool visitTypeName(TypeName node) {
    TypeName toNode = this._toNode as TypeName;
    if (_and(_isEqualNodes(node.name, toNode.name),
        _isEqualNodes(node.typeArguments, toNode.typeArguments))) {
      toNode.type = node.type;
      return true;
    }
    return false;
  }

  @override
  bool visitTypeParameter(TypeParameter node) {
    TypeParameter toNode = this._toNode as TypeParameter;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualNodes(node.name, toNode.name),
        _isEqualTokens(node.extendsKeyword, toNode.extendsKeyword),
        _isEqualNodes(node.bound, toNode.bound));
  }

  @override
  bool visitTypeParameterList(TypeParameterList node) {
    TypeParameterList toNode = this._toNode as TypeParameterList;
    return _and(_isEqualTokens(node.leftBracket, toNode.leftBracket),
        _isEqualNodeLists(node.typeParameters, toNode.typeParameters),
        _isEqualTokens(node.rightBracket, toNode.rightBracket));
  }

  @override
  bool visitVariableDeclaration(VariableDeclaration node) {
    VariableDeclaration toNode = this._toNode as VariableDeclaration;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualNodes(node.name, toNode.name),
        _isEqualTokens(node.equals, toNode.equals),
        _isEqualNodes(node.initializer, toNode.initializer));
  }

  @override
  bool visitVariableDeclarationList(VariableDeclarationList node) {
    VariableDeclarationList toNode = this._toNode as VariableDeclarationList;
    return _and(
        _isEqualNodes(node.documentationComment, toNode.documentationComment),
        _isEqualNodeLists(node.metadata, toNode.metadata),
        _isEqualTokens(node.keyword, toNode.keyword),
        _isEqualNodes(node.type, toNode.type),
        _isEqualNodeLists(node.variables, toNode.variables));
  }

  @override
  bool visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    VariableDeclarationStatement toNode =
        this._toNode as VariableDeclarationStatement;
    return _and(_isEqualNodes(node.variables, toNode.variables),
        _isEqualTokens(node.semicolon, toNode.semicolon));
  }

  @override
  bool visitWhileStatement(WhileStatement node) {
    WhileStatement toNode = this._toNode as WhileStatement;
    return _and(_isEqualTokens(node.whileKeyword, toNode.whileKeyword),
        _isEqualTokens(node.leftParenthesis, toNode.leftParenthesis),
        _isEqualNodes(node.condition, toNode.condition),
        _isEqualTokens(node.rightParenthesis, toNode.rightParenthesis),
        _isEqualNodes(node.body, toNode.body));
  }

  @override
  bool visitWithClause(WithClause node) {
    WithClause toNode = this._toNode as WithClause;
    return _and(_isEqualTokens(node.withKeyword, toNode.withKeyword),
        _isEqualNodeLists(node.mixinTypes, toNode.mixinTypes));
  }

  @override
  bool visitYieldStatement(YieldStatement node) {
    YieldStatement toNode = this._toNode as YieldStatement;
    return _and(_isEqualTokens(node.yieldKeyword, toNode.yieldKeyword),
        _isEqualNodes(node.expression, toNode.expression),
        _isEqualTokens(node.semicolon, toNode.semicolon));
  }

  /**
   * Return `true` if all of the parameters are `true`.
   */
  bool _and(bool b1, bool b2, [bool b3 = true, bool b4 = true, bool b5 = true,
      bool b6 = true, bool b7 = true, bool b8 = true, bool b9 = true,
      bool b10 = true, bool b11 = true, bool b12 = true, bool b13 = true]) {
    // TODO(brianwilkerson) Inline this method.
    return b1 &&
        b2 &&
        b3 &&
        b4 &&
        b5 &&
        b6 &&
        b7 &&
        b8 &&
        b9 &&
        b10 &&
        b11 &&
        b12 &&
        b13;
  }

  /**
   * Return `true` if the [first] and [second] lists of AST nodes have the same
   * size and corresponding elements are equal.
   */
  bool _isEqualNodeLists(NodeList first, NodeList second) {
    if (first == null) {
      return second == null;
    } else if (second == null) {
      return false;
    }
    int size = first.length;
    if (second.length != size) {
      return false;
    }
    bool equal = true;
    for (int i = 0; i < size; i++) {
      if (!_isEqualNodes(first[i], second[i])) {
        equal = false;
      }
    }
    return equal;
  }

  /**
   * Return `true` if the [fromNode] and [toNode] have the same structure. As a
   * side-effect, if the nodes do have the same structure, any resolution data
   * from the first node will be copied to the second node.
   */
  bool _isEqualNodes(AstNode fromNode, AstNode toNode) {
    if (fromNode == null) {
      return toNode == null;
    } else if (toNode == null) {
      return false;
    } else if (fromNode.runtimeType == toNode.runtimeType) {
      this._toNode = toNode;
      return fromNode.accept(this);
    }
    //
    // Check for a simple transformation caused by entering a period.
    //
    if (toNode is PrefixedIdentifier) {
      SimpleIdentifier prefix = toNode.prefix;
      if (fromNode.runtimeType == prefix.runtimeType) {
        this._toNode = prefix;
        return fromNode.accept(this);
      }
    } else if (toNode is PropertyAccess) {
      Expression target = toNode.target;
      if (fromNode.runtimeType == target.runtimeType) {
        this._toNode = target;
        return fromNode.accept(this);
      }
    }
    return false;
  }

  /**
   * Return `true` if the [first] and [second] arrays of tokens have the same
   * length and corresponding elements are equal.
   */
  bool _isEqualTokenLists(List<Token> first, List<Token> second) {
    int length = first.length;
    if (second.length != length) {
      return false;
    }
    for (int i = 0; i < length; i++) {
      if (!_isEqualTokens(first[i], second[i])) {
        return false;
      }
    }
    return true;
  }

  /**
   * Return `true` if the [first] and [second] tokens have the same structure.
   */
  bool _isEqualTokens(Token first, Token second) {
    if (first == null) {
      return second == null;
    } else if (second == null) {
      return false;
    }
    return first.lexeme == second.lexeme;
  }

  /**
   * Copy resolution data from the [fromNode] to the [toNode].
   */
  static void copyResolutionData(AstNode fromNode, AstNode toNode) {
    ResolutionCopier copier = new ResolutionCopier();
    copier._isEqualNodes(fromNode, toNode);
  }
}
