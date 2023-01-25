import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview.dart';
import 'package:boardview/boardview_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import '../../../../../core/util/device/device_utils.dart';
import '../../../../../core/util/locale/app_localization.dart';
import '../../../../../core/util/routes/routes.dart';
import '../../../../../core/widgets/progress_indicator_widget.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../../../domain/models/board/board.dart';
import '../../../domain/models/project/project.dart';
import '../../../domain/usecases/board/boardItem_store.dart';
import '../../../domain/usecases/board/boardItem_store_validation.dart';
import '../../../domain/usecases/board/board_list_store.dart';
import '../../../domain/usecases/board/board_store.dart';
import '../../../domain/usecases/board/board_store_validation.dart';
import '../../../domain/usecases/organization/organization_list_store.dart';
import '../../../domain/usecases/organization/organization_store.dart';
import '../../../domain/usecases/organization/organization_store_validation.dart';
import '../../../domain/usecases/organization/project_store_validation.dart';
import '../../../domain/usecases/theme/theme_store.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  //stores:---------------------------------------------------------------------
  late BoardListStore _boardListStore;
  late OrganizationListStore _organizationListStore;
  late ThemeStore _themeStore;
  BoardViewController boardViewController =  BoardViewController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late final OrganizationStoreValidation _organizationStoreValidation =
       OrganizationStoreValidation();
  late final BoardStoreValidation _boardStoreValidation =  BoardStoreValidation();
  late final BoardItemStoreValidation _boardItemStoreValidation =
       BoardItemStoreValidation();
  late final ProjectStoreValidation _projectStoreValidation =
       ProjectStoreValidation();

  final TextEditingController _titleProjectController = TextEditingController();
  final TextEditingController _descriptionProjectController = TextEditingController();

  final TextEditingController _boardItemTitleController = TextEditingController();
  final TextEditingController _boardItemDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // initializing stores
    _themeStore = Provider.of<ThemeStore>(context);
    _boardListStore = Provider.of<BoardListStore>(context);
    _organizationListStore = Provider.of<OrganizationListStore>(context);

    // check to see if already called api
    if (!_boardListStore.loading) {
      _boardListStore.getBoards(_boardListStore.project!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

// app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: (String value) {
            switch (value) {
              case "Edit":
                Project project = _boardListStore.project!;

                int organizationIndex = _organizationListStore
                    .getOrganizationIndex(project.organizationId!);

                if (organizationIndex != -1) {
                  OrganizationStore orgStore = _organizationListStore
                      .organizationList[organizationIndex];

                  int projectIndex = orgStore.getProjectIndex(project.id!);

                  _projectStoreValidation
                      .setTitle(orgStore.projectList[projectIndex].title!);
                  _projectStoreValidation.setDescription(
                      orgStore.projectList[projectIndex].description!);

                  _showProjectEditBottomSheet(context);
                }
                break;
              case "Delete":
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text(
                        'Are you sure you wish to delete this item?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                      ),
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () async {
                          Project project = _boardListStore.project!;

                          int organizationIndex = _organizationListStore
                              .getOrganizationIndex(project.organizationId!);

                          if (organizationIndex != -1) {
                            OrganizationStore orgStore = _organizationListStore
                                .organizationList[organizationIndex];

                            await orgStore.deleteProject(project);
                            _boardListStore.project = null;

                            Navigator.pop(context, 'OK');
                            Navigator.pushNamedAndRemoveUntil(context,
                                Routes.organizationList, (route) => false);
                          }
                        },
                      ),
                    ],
                  ),
                );
                break;
            }
          },
          itemBuilder: (_) => <PopupMenuItem<String>>[
            PopupMenuItem<String>(
              value: "Edit",
              child: Row(
                children: [
                  Icon(Icons.edit,
                      color: _themeStore.darkMode
                          ? Colors.white
                          : Colors.blue.shade200),
                  const SizedBox(width: 15.0),
                  const Text("Edit"),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: "Delete",
              child: Row(
                children: [
                  Icon(Icons.delete,
                      color: _themeStore.darkMode
                          ? Colors.white
                          : Colors.blue.shade200),
                  const SizedBox(width: 15.0),
                  const Text("Delete"),
                ],
              ),
            ),
          ],
        ),
      ],
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      title: Observer(builder: (context) {
        Project project = _boardListStore.project!;
        int organizationIndex = _organizationListStore
            .getOrganizationIndex(project.organizationId!);
        if (organizationIndex == -1) {
          return const Text(
            "Deleted Project",
            style: TextStyle(color: Colors.white),
          );
        } else {
          OrganizationStore orgStore =
              _organizationListStore.organizationList[organizationIndex];

          return Text(
            orgStore.projectList[orgStore.getProjectIndex(project.id!)].title!,
            style: const TextStyle(color: Colors.white),
          );
        }
      }),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        _handleErrorMessage(),
        _buildProjectsContent(),
      ],
    );
  }

  Widget _buildProjectsContent() {
    return Observer(builder: (context) {
      if (_boardListStore.loading) {
        return const CustomProgressIndicatorWidget();
      } else {
        List<BoardList> _lists = [];

        for (int i = 0; i < _boardListStore.boardList.length; i++) {
          _lists.add(
              _createBoardList(_boardListStore.boardList[i], i) as BoardList);
        }
        // Add empty BoardList with "Add Board" button at the end
        _lists.add(BoardList(
          items: const [],
          draggable: false,
          onStartDragList: (int? listIndex) {},
          onDropList: (int? listIndex, int? oldListIndex) {
            //TODO: return boardItem to original board
          },
          backgroundColor: _themeStore.darkMode
              ? Colors.white70
              : const Color.fromARGB(255, 235, 236, 240),
          footer: SizedBox(
              width: double.infinity,
              height: 36.0,
              child: TextButton(
                child: Text("Add Board",
                    style: TextStyle(
                        color: _themeStore.darkMode
                            ? Colors.white70
                            : Colors.black)),
                onPressed: () {
                  _showBoardBottomSheet(context);
                },
              )),
        ));

        return Material(
          child: BoardView(
            middleWidget: _middleWidget(),
            itemInMiddleWidget: (check) {
              if (kDebugMode) {
                print(check);
              }
            },
            onDropItemInMiddleWidget: (index1, index2, double) async {
              if (index1 != null && index2 == null) {
                Board deleteBoard = _boardListStore.boardList[index1];
                _showDeleteLoadingMessage("Deleting board.");
                await _boardListStore.deleteBoard(deleteBoard);
              }

              if (index1 != null && index2 != null) {
                _showDeleteLoadingMessage("Deleting board item.");
                await _boardListStore.deleteBoardItem(index1, index2);
              }
            },
            lists: _lists,
            boardViewController: boardViewController,
          ),
        );
      }
    });
  }

  //-------------------------Board List-------------------------
  Widget _createBoardList(BoardStore boardStore, int listIndex) {
    List<BoardItem> items = [];

    if (boardStore.loading) {
      items.add(BoardItem(
        item: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Container(
                    margin: const EdgeInsets.all(15.0),
                    child: const SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        )))),
          ],
        ),
      ));

      return BoardList(
        items: items,
        headerBackgroundColor: _themeStore.darkMode
            ? Colors.black12
            : const Color.fromARGB(255, 235, 236, 240),
        backgroundColor: _themeStore.darkMode
            ? Colors.white70
            : const Color.fromARGB(255, 235, 236, 240),
        header: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    boardStore.title!,
                    style: TextStyle(
                        fontSize: 18,
                        color: _themeStore.darkMode
                            ? Colors.black38
                            : Colors.black),
                  ))),
        ],
      );
    } else {
      for (int i = 0; i < boardStore.boardItemList.length; i++) {
        items.add(buildBoardItem(boardStore.boardItemList[i]) as BoardItem);
      }
      return BoardList(
        items: items,
        footer: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            _showBoardItemBottomSheet(context, listIndex);
          },
        ),
        onStartDragList: (int? listIndex) {},
        onTapList: (int? listIndex) async {},
        onDropList: (int? listIndex, int? oldListIndex) {
          //Update our local list data
          // var list = _listData[oldListIndex!];
          // _listData.removeAt(oldListIndex);
          // _listData.insert(listIndex!, list);
        },
        headerBackgroundColor: _themeStore.darkMode
            ? Colors.white70
            : const Color.fromARGB(255, 235, 236, 240),
        backgroundColor: _themeStore.darkMode
            ? Colors.white70
            : const Color.fromARGB(255, 235, 236, 240),
        header: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                boardStore.title!,
                style: TextStyle(
                    fontSize: 18,
                    color:
                        _themeStore.darkMode ? Colors.black38 : Colors.black),
              ),
            ),
          ),
        ],
      );
    }
  }

  //------------------------Board Item-------------------------
  Widget buildBoardItem(BoardItemStore itemStore) {
    return BoardItem(
      onStartDragItem:
          (int? listIndex, int? itemIndex, BoardItemState state) {},
      onDropItem: (int? listIndex, int? itemIndex, int? oldListIndex,
          int? oldItemIndex, BoardItemState state) {
        //Used to update our local item data
        // var item = _listData[oldListIndex!].items[oldItemIndex];
        // _listData[oldListIndex].items.removeAt(oldItemIndex);
        // _listData[listIndex!].items.insert(itemIndex, item);
      },
      onTapItem:
          (int? listIndex, int? itemIndex, BoardItemState state) async {},
      item: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(itemStore.title!),
        ),
      ),
    );
  }

  //-------------------------Bottom Sheet-------------------------
  void _showProjectEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 10.0, right: 10.0, bottom: 15.0),
                      child: _buildEditProjectForm(),
                    ),
                  ]),
            );
          });
        });
  }

  Widget _buildEditProjectForm() {
    return Container(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.supervised_user_circle_outlined,
                      color: _themeStore.darkMode
                          ? Colors.white
                          : Colors.blue.shade200),
                  const SizedBox(width: 15.0),
                  const Text("Edit Project"),
                ],
              ),
              const SizedBox(width: 10.0),
              OutlinedButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.black45, disabledForegroundColor: Colors.red.withOpacity(0.38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(255.0),
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close,
                    color:
                        _themeStore.darkMode ? Colors.white : Colors.black45),
              ),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          Observer(builder: (context) {
            return TextFieldWidget(
              hint: AppLocalizations.of(context).translate('project_tv_title'),
              inputType: TextInputType.emailAddress,
              icon: Icons.create,
              iconColor:
                  _themeStore.darkMode ? Colors.white70 : Colors.blue.shade200,
              initValue: _projectStoreValidation.title,
              inputAction: TextInputAction.next,
              autoFocus: false,
              onChanged: (value) {
                _projectStoreValidation.setTitle(value);
              },
              onFieldSubmitted: (value) {
                //  FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              errorText: _projectStoreValidation.projectErrorStore.title,
            );
          }),
          const SizedBox(
            height: 20.0,
          ),
          Observer(
            builder: (context) {
              return TextFieldWidget(
                hint: AppLocalizations.of(context)
                    .translate('project_tv_description'),
                inputType: TextInputType.emailAddress,
                icon: Icons.wysiwyg_outlined,
                iconColor: _themeStore.darkMode
                    ? Colors.white70
                    : Colors.blue.shade200,
                initValue: _projectStoreValidation.description,
                inputAction: TextInputAction.next,
                autoFocus: false,
                onChanged: (value) {
                  _projectStoreValidation.setDescription(value);
                },
                onFieldSubmitted: (value) {
                },
                errorText:
                    _projectStoreValidation.projectErrorStore.description,
              );
            },
          ),
          const SizedBox(
            height: 40.0,
          ),
          ElevatedButton(
              style: TextButton.styleFrom(
                  primary: Colors.blue,
                  onSurface: Colors.red,
                  minimumSize: const Size(128, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  )),
              onPressed: () {
                if (_projectStoreValidation.canAdd) {
                  Project pr = Project(
                      organizationId: _boardListStore.project?.organizationId,
                      id: _boardListStore.project?.id,
                      title: _projectStoreValidation.title,
                      description: _projectStoreValidation.description);

                  _organizationListStore.organizationList[
                          _organizationListStore.getOrganizationIndex(
                              _boardListStore.project?.organizationId)]
                      .updateProject(pr);

                  DeviceUtils.hideKeyboard(context);
                  Navigator.of(context).pop();
                  _titleProjectController.clear();
                  _descriptionProjectController.clear();
                  // TODO: update value in database
                } else {
                  _showErrorMessage('Please fill in all fields');
                }
              },
              child:
                  const Text('Update Project', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _showBoardBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 10.0, right: 10.0, bottom: 15.0),
                      child: _buildCreateBoardForm(),
                    ),
                  ]),
            );
          });
        });
  }

  Widget _buildCreateBoardForm() {
    return Container(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.supervised_user_circle_outlined,
                      color: _themeStore.darkMode
                          ? Colors.white
                          : Colors.blue.shade200),
                  const SizedBox(width: 15.0),
                  const Text("Add New Board"),
                ],
              ),
              const SizedBox(width: 10.0),
              OutlinedButton(
                style: TextButton.styleFrom(
                    primary: Colors.black45,
                    onSurface: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(255.0),
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close,
                    color:
                        _themeStore.darkMode ? Colors.white : Colors.black45),
              ),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          Observer(builder: (context) {
            return TextFieldWidget(
              hint: AppLocalizations.of(context).translate('board_tv_title'),
              inputType: TextInputType.emailAddress,
              icon: Icons.create,
              iconColor:
                  _themeStore.darkMode ? Colors.white70 : Colors.blue.shade200,
              textController: _titleController,
              inputAction: TextInputAction.next,
              autoFocus: false,
              onChanged: (value) {
                _boardStoreValidation.setTitle(_titleController.text);
              },
              onFieldSubmitted: (value) {
                //  FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              errorText: _boardStoreValidation.boardErrorStore.title,
            );
          }),
          const SizedBox(
            height: 20.0,
          ),
          Observer(
            builder: (context) {
              return TextFieldWidget(
                hint: AppLocalizations.of(context)
                    .translate('board_tv_description'),
                inputType: TextInputType.emailAddress,
                icon: Icons.wysiwyg_outlined,
                iconColor: _themeStore.darkMode
                    ? Colors.white70
                    : Colors.blue.shade200,
                textController: _descriptionController,
                inputAction: TextInputAction.next,
                autoFocus: false,
                onChanged: (value) {
                  _boardStoreValidation
                      .setDescription(_descriptionController.text);
                },
                onFieldSubmitted: (value) {
                  //  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
                errorText: _boardStoreValidation.boardErrorStore.description,
              );
            },
          ),
          const SizedBox(
            height: 40.0,
          ),
          Observer(
            builder: (context) {
              return _boardListStore.insertBoardLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: TextButton.styleFrom(
                          primary: Colors.blue,
                          onSurface: Colors.red,
                          minimumSize: const Size(128, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          )),
                      onPressed: () async {
                        if (_boardStoreValidation.canAdd) {
                          DeviceUtils.hideKeyboard(context);
                          Project project = _boardListStore.project!;
                          await _boardListStore.insertBoard(
                              project.id!,
                              _titleController.text,
                              _descriptionController.text);
                          _boardStoreValidation.reset();
                          _titleController.clear();
                          _descriptionController.clear();
                          Navigator.of(context).pop();
                        } else {
                          _showErrorMessage('Please fill in all fields');
                        }
                      },
                      child: const Text('Create New Board',
                          style: TextStyle(color: Colors.white)));
            },
          )
        ],
      ),
    );
  }

  void _showBoardItemBottomSheet(BuildContext context, int listIndex) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 10.0, right: 10.0, bottom: 15.0),
                      child: _buildCreateBoardItemForm(listIndex),
                    ),
                  ]),
            );
          });
        });
  }

  Widget _buildCreateBoardItemForm(int listIndex) {
    return Container(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.supervised_user_circle_outlined,
                      color: _themeStore.darkMode
                          ? Colors.white
                          : Colors.blue.shade200),
                  const SizedBox(width: 15.0),
                  const Text("Add New Board Item"),
                ],
              ),
              const SizedBox(width: 10.0),
              OutlinedButton(
                style: TextButton.styleFrom(
                    primary: Colors.black45,
                    onSurface: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(255.0),
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close,
                    color:
                        _themeStore.darkMode ? Colors.white : Colors.black45),
              ),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          Observer(builder: (context) {
            return TextFieldWidget(
              hint:
                  AppLocalizations.of(context).translate('boardItem_tv_title'),
              inputType: TextInputType.emailAddress,
              icon: Icons.create,
              iconColor:
                  _themeStore.darkMode ? Colors.white70 : Colors.blue.shade200,
              textController: _boardItemTitleController,
              inputAction: TextInputAction.next,
              autoFocus: false,
              onChanged: (value) {
                _boardItemStoreValidation
                    .setTitle(_boardItemTitleController.text);
              },
              onFieldSubmitted: (value) {
                //  FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              errorText: _boardItemStoreValidation.boardItemErrorStore.title,
            );
          }),
          const SizedBox(
            height: 20.0,
          ),
          Observer(
            builder: (context) {
              return TextFieldWidget(
                hint: AppLocalizations.of(context)
                    .translate('boardItem_tv_description'),
                inputType: TextInputType.emailAddress,
                icon: Icons.wysiwyg_outlined,
                iconColor: _themeStore.darkMode
                    ? Colors.white70
                    : Colors.blue.shade200,
                textController: _boardItemDescriptionController,
                inputAction: TextInputAction.next,
                autoFocus: false,
                onChanged: (value) {
                  _boardItemStoreValidation
                      .setDescription(_boardItemDescriptionController.text);
                },
                onFieldSubmitted: (value) {
                  //  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
                errorText:
                    _boardItemStoreValidation.boardItemErrorStore.description,
              );
            },
          ),
          const SizedBox(
            height: 40.0,
          ),
          Observer(
            builder: (context) {
              return _boardListStore.insertBoardItemLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.blue, disabledForegroundColor: Colors.red.withOpacity(0.38),
                          minimumSize: const Size(128, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          )),
                      onPressed: () async {
                        if (_boardItemStoreValidation.canAdd) {
                          DeviceUtils.hideKeyboard(context);
                          BoardStore boardStore =
                              _boardListStore.boardList[listIndex];
                          await _boardListStore.insertBoardItem(
                              boardStore.id!,
                              _boardItemTitleController.text,
                              _boardItemDescriptionController.text);
                          _boardItemStoreValidation.reset();
                          _boardItemTitleController.clear();
                          _boardItemDescriptionController.clear();
                          Navigator.of(context).pop();
                        } else {
                          _showErrorMessage('Please fill in all fields');
                        }
                      },
                      child: const Text('Create New Board Item',
                          style: TextStyle(color: Colors.white)));
            },
          )
        ],
      ),
    );
  }

  Widget _middleWidget() {
    return Positioned(
      bottom: 0,
      child: Container(
          width: MediaQuery.of(context).size.width,
          height: 50,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Colors.red),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Delete",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
              Icon(
                Icons.delete,
                color: Colors.white,
                size: 20,
              )
            ],
          )),
    );
  }

  // General Methods:-----------------------------------------------------------
  Widget _handleErrorMessage() {
    return Observer(
      builder: (context) {
        if (_boardListStore.errorStore.errorMessage.isNotEmpty) {
          return _showErrorMessage(_boardListStore.errorStore.errorMessage);
        }
        return const SizedBox.shrink();
      },
    );
  }

  _showErrorMessage(String message) {
    Future.delayed(const Duration(milliseconds: 0), () {
      if (message.isNotEmpty) {
        FlushbarHelper.createError(
          message: message,
          title: AppLocalizations.of(context).translate('board_tv_error'),
          duration: const Duration(seconds: 3),
        ).show(context);
      }
    });

    return const SizedBox.shrink();
  }

  _showDeleteLoadingMessage(String message) {
    Future.delayed(const Duration(milliseconds: 0), () {
      FlushbarHelper.createLoading(
        linearProgressIndicator: const LinearProgressIndicator(),
        message: message,
        title: "Delete",
        duration: const Duration(seconds: 2),
      ).show(context);
    });

    return const SizedBox.shrink();
  }
}
