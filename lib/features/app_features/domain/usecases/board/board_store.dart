
import 'package:kanban/features/app_features/domain/models/board/board.dart';
import 'package:kanban/features/app_features/domain/usecases/board/boardItem_store.dart';
import 'package:mobx/mobx.dart';

import '../../../../../core/util/dio/dio_error_util.dart';
import '../../../data/repositories/repository.dart';
import '../../models/boardItem/boardItem.dart';
import '../../models/boardItem/boardItem_list.dart';
import '../error/error_store.dart';

part 'board_store.g.dart';

class BoardStore = _BoardStore with _$BoardStore;

abstract class _BoardStore extends Board with Store {
  // repository instance
  late Repository _repository;

  // store for handling errors
  final ErrorStore errorStore = ErrorStore();

  // constructor:---------------------------------------------------------------
  _BoardStore(
    Repository repository, {
    projectId,
    id,
    title,
    description,
  }) : super(
            projectId: projectId,
            id: id,
            title: title,
            description: description) {
    this._repository = repository;
  }

  // store variables:-----------------------------------------------------------
  static ObservableFuture<BoardItemList?> emptyBoardResponse =
      ObservableFuture.value(null);

  @observable
  ObservableFuture<BoardItemList?> fetchBoardsFuture =
      ObservableFuture<BoardItemList?>(emptyBoardResponse);

  @observable
  ObservableList<BoardItemStore> boardItemList =
      ObservableList<BoardItemStore>();

  @observable
  bool success = false;

  @computed
  bool get loading => fetchBoardsFuture.status == FutureStatus.pending;

  int getBoardItemIndex(boardItemId) =>
      boardItemList.indexWhere((element) => element.id == boardItemId);

  // actions:-------------------------------------------------------------------
  @action
  Future getBoardItems(int boardId) async {
    final future = _repository.getBoardItems(boardId);
    fetchBoardsFuture = ObservableFuture(future);

    future.then((boardItemList) {
      if (boardItemList.boardItemList != null) {
        for (BoardItem boardItem in boardItemList.boardItemList!) {
          addBoardItemList(boardItem);
        }
      }
    }).catchError((error) {
      errorStore.errorMessage = DioErrorUtil.handleError(error);
    });
  }

  @action
  void addBoardItemList(BoardItem boardItem) {
    BoardItemStore boardItemStore = BoardItemStore(_repository,
        boardId: boardItem.boardId,
        id: boardItem.id,
        title: boardItem.title,
        description: boardItem.description);
    boardItemList.add(boardItemStore);
  }

}
