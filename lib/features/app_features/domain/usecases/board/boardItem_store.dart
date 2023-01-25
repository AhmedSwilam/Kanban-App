
import 'package:kanban/features/app_features/domain/models/boardItem/boardItem.dart';
import 'package:mobx/mobx.dart';

import '../../../data/repositories/repository.dart';
import '../error/error_store.dart';

part 'boardItem_store.g.dart';

class BoardItemStore = _BoardItemStore with _$BoardItemStore;

abstract class _BoardItemStore extends BoardItem with Store {
  // repository instance
  late Repository _repository;

  // store for handling errors
  final ErrorStore errorStore = ErrorStore();

  // constructor:---------------------------------------------------------------
  _BoardItemStore(
      Repository repository, {
        boardId,
        id,
        title,
        description,
      }) : super(boardId: boardId, id: id, title: title, description: description) {
    this._repository = repository;
  }

  // store variables:-----------------------------------------------------------
  // actions:-------------------------------------------------------------------
}
