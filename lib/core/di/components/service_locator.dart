
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/app_features/data/datasources/local/datasources/board/board_datasource.dart';
import '../../../features/app_features/data/datasources/local/datasources/boardItem/boardItem_datasource.dart';
import '../../../features/app_features/data/datasources/local/datasources/organization/organization_datasource.dart';
import '../../../features/app_features/data/datasources/local/datasources/post/post_datasource.dart';
import '../../../features/app_features/data/datasources/local/datasources/project/project_datasource.dart';
import '../../../features/app_features/data/datasources/network/apis/board/boardItem_api.dart';
import '../../../features/app_features/data/datasources/network/apis/board/board_api.dart';
import '../../../features/app_features/data/datasources/network/apis/organizations/organization_api.dart';
import '../../../features/app_features/data/datasources/network/apis/posts/post_api.dart';
import '../../../features/app_features/data/datasources/network/apis/projects/project_api.dart';
import '../../../features/app_features/data/datasources/network/dio_client.dart';
import '../../../features/app_features/data/datasources/network/rest_client.dart';
import '../../../features/app_features/data/datasources/sharedpref/shared_preference_helper.dart';
import '../../../features/app_features/data/repositories/repository.dart';
import '../../../features/app_features/domain/usecases/error/error_store.dart';
import '../../../features/app_features/domain/usecases/form/form_store.dart';
import '../../../features/app_features/domain/usecases/language/language_store.dart';
import '../../../features/app_features/domain/usecases/organization/organization_list_store.dart';
import '../../../features/app_features/domain/usecases/post/post_store.dart';
import '../../../features/app_features/domain/usecases/theme/theme_store.dart';
import '../../../features/app_features/domain/usecases/user/user_store.dart';
import '../module/local_module.dart';
import '../module/network_module.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // factories:-----------------------------------------------------------------
  getIt.registerFactory(() => ErrorStore());
  getIt.registerFactory(() => FormStore());

  // async singletons:----------------------------------------------------------
  getIt.registerSingletonAsync<Database>(() => LocalModule.provideDatabase());
  getIt.registerSingletonAsync<SharedPreferences>(
      () => LocalModule.provideSharedPreferences());

  // singletons:----------------------------------------------------------------
  getIt.registerSingleton(
      SharedPreferenceHelper(await getIt.getAsync<SharedPreferences>()));
  getIt.registerSingleton<Dio>(
      NetworkModule.provideDio(getIt<SharedPreferenceHelper>()));
  getIt.registerSingleton(DioClient(getIt<Dio>()));
  getIt.registerSingleton(RestClient());

  // api's:---------------------------------------------------------------------
  getIt.registerSingleton(PostApi(getIt<DioClient>(), getIt<RestClient>()));
  getIt.registerSingleton(OrganizationApi(getIt<DioClient>()));
  getIt.registerSingleton(ProjectApi(getIt<DioClient>()));
  getIt.registerSingleton(BoardApi(getIt<DioClient>()));
  getIt.registerSingleton(BoardItemApi(getIt<DioClient>()));

  // data sources
  getIt.registerSingleton(PostDataSource(await getIt.getAsync<Database>()));
  getIt.registerSingleton(
      OrganizationDataSource(await getIt.getAsync<Database>()));
  getIt.registerSingleton(ProjectDataSource(await getIt.getAsync<Database>()));
  getIt.registerSingleton(BoardDataSource(await getIt.getAsync<Database>()));
  getIt.registerSingleton(BoardItemDataSource(await getIt.getAsync<Database>()));

  // repository:----------------------------------------------------------------
  getIt.registerSingleton(Repository(
    getIt<PostApi>(),
    getIt<OrganizationApi>(),
    getIt<ProjectApi>(),
    getIt<BoardApi>(),
    getIt<BoardItemApi>(),
    getIt<SharedPreferenceHelper>(),
    getIt<PostDataSource>(),
    getIt<OrganizationDataSource>(),
    getIt<ProjectDataSource>(),
    getIt<BoardDataSource>(),
    getIt<BoardItemDataSource>(),
  ));

  // stores:--------------------------------------------------------------------
  getIt.registerSingleton(LanguageStore(getIt<Repository>()));
  getIt.registerSingleton(PostStore(getIt<Repository>()));
  getIt.registerSingleton(OrganizationListStore(getIt<Repository>()));
  getIt.registerSingleton(ThemeStore(getIt<Repository>()));
  getIt.registerSingleton(UserStore(getIt<Repository>()));
}
