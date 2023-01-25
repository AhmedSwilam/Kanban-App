import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../../domain/models/board/board.dart';
import '../../../../../domain/models/board/board_list.dart';
import '../../dio_client.dart';


class BoardApi {
  // dio instance
  final DioClient _dioClient;

  // injecting dio instance
  BoardApi(this._dioClient);

  /// Returns list of organization in response
  Future<BoardList> getBoards(int projectId) async {
    try {
      //final res = await _dioClient.get(Endpoints.getBoards);
      //return BoardList.fromJson(res);

      // Fake API
      List<Board> boards = [];

      List<Board> filteredBoards =
          boards.where((item) => item.projectId == projectId).toList();

      BoardList boardList = BoardList(boards: filteredBoards);

      return await Future.delayed(const Duration(seconds: 1), () => boardList);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }

  Future<Board> insertBoard(int proId, String title, String description) async {
    try {
      //final res = await _dioClient.post(Endpoints.getOrganization + organization.id.toString());
      //return OrganizationList.fromJson(res);

      Board brd = Board(
          id: DateTime.now().millisecond,
          title: title,
          description: description,
          projectId: proId);

      return await Future.delayed(const Duration(seconds: 2), () => brd);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteBoard(int boardId) async {
    try {
      //final res = await _dioClient.delete(Endpoints.deleteBoard + boardId.toString());
      //return Board.fromJson(res);

      return await Future.delayed(const Duration(seconds: 2), () => boardId);
    } catch (e) {
      rethrow;
    }
  }
}
