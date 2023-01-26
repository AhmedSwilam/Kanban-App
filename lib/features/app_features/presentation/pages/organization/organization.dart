import 'package:another_flushbar/flushbar_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_dialog/material_dialog.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/util/device/device_utils.dart';
import '../../../../../core/util/locale/app_localization.dart';
import '../../../../../core/util/routes/routes.dart';
import '../../../../../core/widgets/action_button.dart';
import '../../../../../core/widgets/expandable_fab.dart';
import '../../../../../core/widgets/progress_indicator_widget.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../../../data/datasources/sharedpref/constants/preferences.dart';
import '../../../domain/models/organization/organization.dart';
import '../../../domain/models/project/project.dart';
import '../../../domain/usecases/board/board_list_store.dart';
import '../../../domain/usecases/language/language_store.dart';
import '../../../domain/usecases/organization/organization_list_store.dart';
import '../../../domain/usecases/organization/organization_store.dart';
import '../../../domain/usecases/organization/organization_store_validation.dart';
import '../../../domain/usecases/organization/project_store_validation.dart';
import '../../../domain/usecases/theme/theme_store.dart';

class OrganizationScreen extends StatefulWidget {
  @override
  _OrganizationScreenState createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  //stores:---------------------------------------------------------------------
  late OrganizationListStore _organizationListStore;
  late final OrganizationStoreValidation _organizationStoreValidation =
      OrganizationStoreValidation();
  late final ProjectStoreValidation _projectStoreValidation =
      ProjectStoreValidation();

  late ThemeStore _themeStore;
  late LanguageStore _languageStore;
  late BoardListStore _boardListStore;

  final currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // initializing stores
    _languageStore = Provider.of<LanguageStore>(context);
    _themeStore = Provider.of<ThemeStore>(context);
    _organizationListStore = Provider.of<OrganizationListStore>(context);
    _boardListStore = Provider.of<BoardListStore>(context);

    // check to see if already called api
    if (!_organizationListStore.loading) {
      _organizationListStore.getOrganizations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFloatingActionButton(),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  // floating action button methods:-----------------------------------------------------------
  ExpandableFab _buildFloatingActionButton() {
    return ExpandableFab(
      distance: 70.0,
      children: [
        ActionButton(
          onPressed: () => _showOrganizationBottomSheet(context),
          textWidget:
              const Text("Organization", style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.supervised_user_circle_outlined,
              color: Colors.white),
        ),
        Observer(builder: (context) {
          return _organizationListStore.organizationList.length > 0
              ? ActionButton(
                  onPressed: () => _showProjectBottomSheet(context),
                  textWidget: const Text("Project",
                      style: TextStyle(color: Colors.white)),
                  icon: const Icon(Icons.table_chart_outlined,
                      color: Colors.white),
                )
              : const SizedBox();
        }),
      ],
    );
  }

  void _showOrganizationBottomSheet(BuildContext context) {
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
                      child: _buildCreateOrganizationForm(),
                    ),
                  ]),
            );
          });
        });
  }

  Widget _buildCreateOrganizationForm() {
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
                  const Text("Add New Organization"),
                ],
              ),
              const SizedBox(width: 10.0),
              OutlinedButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.black45,
                    disabledForegroundColor: Colors.red.withOpacity(0.38),
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
              hint: AppLocalizations.of(context)
                  .translate('organization_tv_title'),
              inputType: TextInputType.emailAddress,
              icon: Icons.create,
              iconColor:
                  _themeStore.darkMode ? Colors.white70 : Colors.blue.shade200,
              textController: _titleController,
              inputAction: TextInputAction.next,
              autoFocus: false,
              onChanged: (value) {
                _organizationStoreValidation.setTitle(_titleController.text);
              },
              onFieldSubmitted: (value) {
                //  FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              errorText:
                  _organizationStoreValidation.organizationErrorStore.title,
            );
          }),
          const SizedBox(
            height: 20.0,
          ),
          Observer(
            builder: (context) {
              return TextFieldWidget(
                hint: AppLocalizations.of(context)
                    .translate('organization_tv_description'),
                inputType: TextInputType.emailAddress,
                icon: Icons.wysiwyg_outlined,
                iconColor: _themeStore.darkMode
                    ? Colors.white70
                    : Colors.blue.shade200,
                textController: _descriptionController,
                inputAction: TextInputAction.next,
                autoFocus: false,
                onChanged: (value) {
                  _organizationStoreValidation
                      .setDescription(_descriptionController.text);
                },
                onFieldSubmitted: (value) {
                  //  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
                errorText: _organizationStoreValidation
                    .organizationErrorStore.description,
              );
            },
          ),
          const SizedBox(
            height: 40.0,
          ),
          Observer(
            builder: (context) {
              return _organizationListStore.insertLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          disabledForegroundColor: Colors.red.withOpacity(0.38),
                          minimumSize: const Size(128, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          )),
                      onPressed: () async {
                        if (_organizationStoreValidation.canAdd) {
                          DeviceUtils.hideKeyboard(context);
                          await _organizationListStore.insertOrganizations(
                              _titleController.text,
                              _descriptionController.text);

                          _organizationStoreValidation.reset();
                          _titleController.clear();
                          _descriptionController.clear();
                          Navigator.of(context).pop();
                        } else {
                          _showErrorMessage('Please fill in all fields');
                        }
                      },
                      child: const Text('Save New Organization',
                          style: TextStyle(color: Colors.white)));
            },
          )
        ],
      ),
    );
  }

  void _showProjectBottomSheet(BuildContext context) {
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
                      child: _buildCreateProjectForm(ctx),
                    ),
                  ]),
            );
          });
        });
  }

  Widget _buildCreateProjectForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: Column(children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.table_chart_outlined,
                        color: _themeStore.darkMode
                            ? Colors.white
                            : Colors.blue.shade200),
                    const SizedBox(width: 15.0),
                    const Text("Add New Project"),
                  ],
                ),
                const SizedBox(width: 10.0),
                OutlinedButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.black45,
                      disabledForegroundColor: Colors.red.withOpacity(0.38),
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
            Row(
              children: [
                Icon(
                  Icons.home,
                  color: _themeStore.darkMode
                      ? Colors.white70
                      : Colors.blue.shade200,
                ),
                const SizedBox(
                  width: 17.0,
                ),
                Observer(
                  builder: (context) => DropdownButton<String>(
                    value: _projectStoreValidation.selectedOrgId.toString(),
                    iconEnabledColor:
                        _themeStore.darkMode ? Colors.white : Colors.blue,
                    dropdownColor: Colors.white,
                    items: _organizationListStore.organizationList
                        .map((dropdownItem) {
                      return DropdownMenuItem<String>(
                        value: dropdownItem.id.toString(),
                        child: Text(dropdownItem.title!,
                            style: TextStyle(
                                color: _themeStore.darkMode
                                    ? Colors.blue
                                    : Colors.blue)),
                      );
                    }).toList(),
                    onChanged: (newVal) {
                      _projectStoreValidation
                          .setSelectedOrgId(int.parse(newVal!));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
          ],
        ),
        Observer(builder: (context) {
          return TextFieldWidget(
            hint: AppLocalizations.of(context).translate('project_tv_title'),
            inputType: TextInputType.emailAddress,
            icon: Icons.create,
            iconColor:
                _themeStore.darkMode ? Colors.white70 : Colors.blue.shade200,
            textController: _projectTitleController,
            inputAction: TextInputAction.next,
            autoFocus: false,
            onChanged: (value) {
              _projectStoreValidation.setTitle(_projectTitleController.text);
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
              iconColor:
                  _themeStore.darkMode ? Colors.white70 : Colors.blue.shade200,
              textController: _projectDescriptionController,
              inputAction: TextInputAction.next,
              autoFocus: false,
              onChanged: (value) {
                _projectStoreValidation
                    .setDescription(_projectDescriptionController.text);
              },
              onFieldSubmitted: (value) {
                //  FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              errorText: _projectStoreValidation.projectErrorStore.description,
            );
          },
        ),
        const SizedBox(
          height: 40.0,
        ),
        Observer(builder: (context) {
          return _organizationListStore
                  .organizationList[_organizationListStore.getOrganizationIndex(
                      _projectStoreValidation.selectedOrgId)]
                  .insertLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      disabledForegroundColor: Colors.red.withOpacity(0.38),
                      minimumSize: const Size(128, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      )),
                  onPressed: () async {
                    if (_projectStoreValidation.canAdd) {
                      DeviceUtils.hideKeyboard(context);
                      await _organizationListStore.organizationList[
                              _organizationListStore.getOrganizationIndex(
                                  _projectStoreValidation.selectedOrgId)]
                          .insertProject(
                              _projectStoreValidation.selectedOrgId,
                              _projectTitleController.text,
                              _projectDescriptionController.text);

                      _projectStoreValidation.reset();
                      _projectTitleController.clear();
                      _projectDescriptionController.clear();
                      Navigator.of(context).pop();
                    } else {
                      _showErrorMessage('Please fill in all fields');
                    }
                  },
                  child: const Text('Save New Project',
                      style: TextStyle(color: Colors.white)));
        }),
      ]),
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      title: Text(
        AppLocalizations.of(context).translate('organization_tv_organizations'),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // drawer methods:-----------------------------------------------------------
  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: _themeStore.darkMode ? Colors.black12 : Colors.blue,
                border: const Border(
                    bottom: BorderSide(width: 1.0, color: Colors.black12)),
              ),
              child: Stack(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, left: 15.0),
                  child: SizedBox(
                    height: 100,
                      width: double.infinity,
                      child: Image.asset("assets/images/kanban.png")),
                ),
                Positioned(
                  bottom: 12.0,
                  left: 16.0,
                  child: currentUser!.email != null
                      ? Text(currentUser!.email!,
                          style: TextStyle(
                              color: _themeStore.darkMode
                                  ? Colors.blue
                                  : Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500))
                      : const Text("John Doe"),
                )
              ])),
          ListTile(
            title: Text('Blogs',
                style: TextStyle(
                    color:
                        Theme.of(context).primaryTextTheme.bodyText1!.color)),
            onTap: () {
              Navigator.pushNamed(context, Routes.home);
            },
          ),
          _buildThemeButton(),
          _buildLanguageButton(),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildThemeButton() {
    return Observer(
      builder: (context) {
        return ListTile(
          onTap: () {
            _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
          },
          title: Text(
            "Toggle Theme",
            style: TextStyle(
                color: Theme.of(context).primaryTextTheme.bodyText1!.color),
          ),
          trailing: Icon(
            _themeStore.darkMode ? Icons.brightness_5 : Icons.brightness_3,
            color: Theme.of(context).primaryTextTheme.bodyText1!.color,
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return ListTile(
      onTap: () {
        SharedPreferences.getInstance().then((preference) {
          preference.setBool(Preferences.is_logged_in, false);
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });
      },
      title: Text("Log Out",
          style: TextStyle(
              color: Theme.of(context).primaryTextTheme.bodyText1!.color)),
      trailing: Icon(Icons.logout,
          color: Theme.of(context).primaryTextTheme.bodyText1!.color),
    );
  }

  Widget _buildLanguageButton() {
    return ListTile(
      onTap: () {
        _buildLanguageDialog();
      },
      title: Text("Choose Language",
          style: TextStyle(
              color: Theme.of(context).primaryTextTheme.bodyText1!.color)),
      trailing: Icon(
        Icons.language,
        color: Theme.of(context).primaryTextTheme.bodyText1!.color,
      ),
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
      return _organizationListStore.loading
          ? const CustomProgressIndicatorWidget()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(child: _buildProjectsExpansion()),
            );
    });
  }

  Widget _buildProjectsExpansion() {
    return _organizationListStore.organizationList.length != 0
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: _organizationListStore.organizationList.length,
            itemBuilder: (BuildContext context, int index) {
              return Observer(builder: (_) {
                // set firstOrganization for the Dropdown when adding Projects
                _projectStoreValidation.setSelectedOrgId(
                    _organizationListStore.organizationList[0].id!);
                return _buildOrganizationItem(
                    _organizationListStore.organizationList[index]);
              });
            },
          )
        : Center(
            child: Text(
              AppLocalizations.of(context)
                  .translate('organization_tv_no_organization_found'),
            ),
          );
  }

  Widget _buildOrganizationItem(OrganizationStore organizationStore) {
    return Dismissible(
      key: ValueKey<int>(organizationStore.id!),
      background: Container(
        color: Colors.red,
        child: const Icon(Icons.delete),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: const Text("Are you sure you wish to delete this item?"),
              actions: <Widget>[
                GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("DELETE"),
                    )),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("CANCEL"),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (DismissDirection direction) {
        Organization org = Organization(
            id: organizationStore.id,
            title: organizationStore.title,
            description: organizationStore.description,
            userId: organizationStore.userId);
        _organizationListStore.deleteOrganization(org);
      },
      child: Card(
        child: ExpansionTile(
            iconColor: _themeStore.darkMode ? Colors.white : Colors.black,
            maintainState: true,
            title: Text(
              organizationStore.title!,
              style: TextStyle(
                  color: _themeStore.darkMode ? Colors.white : Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500),
            ),
            children: <Widget>[
              organizationStore.loading
                  ? const ListTile(title: Text("loading.."))
                  : Observer(builder: (_) {
                      return _buildProjectItemList(
                          organizationStore.projectList);
                    })
            ]),
      ),
    );
  }

  Widget _buildProjectItemList(ObservableList<Project>? projectList) {
    if (projectList != null && projectList.length != 0) {
      List<Widget> reasonList = [];
      for (Project p in projectList) {
        reasonList.add(ListTile(
            title: Text(p.title!,
                style: TextStyle(
                    fontSize: 14.0,
                    color: _themeStore.darkMode
                        ? Colors.white70
                        : Colors.black54)),
            onTap: () {
              _boardListStore.setProject(p);
              Navigator.pushNamed(context, Routes.board);
            }));
      }
      return Column(children: reasonList);
    }
    return Column(children: const [
      ListTile(title: Text("No Projects!")),
    ]);
  }

  Widget _handleErrorMessage() {
    return Observer(
      builder: (context) {
        if (_organizationListStore.errorStore.errorMessage.isNotEmpty) {
          return _showErrorMessage(
              _organizationListStore.errorStore.errorMessage);
        }

        return const SizedBox.shrink();
      },
    );
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    Future.delayed(const Duration(milliseconds: 0), () {
      if (message.isNotEmpty) {
        FlushbarHelper.createError(
          message: message,
          title:
              AppLocalizations.of(context).translate('organization_tv_error'),
          duration: const Duration(seconds: 3),
        ).show(context);
      }
    });

    return const SizedBox.shrink();
  }

  _buildLanguageDialog() {
    _showDialog<String>(
      context: context,
      child: MaterialDialog(
        borderRadius: 5.0,
        enableFullWidth: true,
        title: Text(
          AppLocalizations.of(context).translate('home_tv_choose_language'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        headerColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        closeButtonColor: Colors.white,
        enableCloseButton: true,
        enableBackButton: false,
        onCloseButtonClicked: () {
          Navigator.of(context).pop();
        },
        children: _languageStore.supportedLanguages
            .map(
              (object) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.all(0.0),
                title: Text(
                  object.language!,
                  style: TextStyle(
                    color: _languageStore.locale == object.locale
                        ? Theme.of(context).primaryColor
                        : _themeStore.darkMode
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  // change user language based on selected locale
                  _languageStore.changeLanguage(object.locale!);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  _showDialog<T>({required BuildContext context, required Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T? value) {
      // The value passed to Navigator.pop() or null.
    });
  }
}
