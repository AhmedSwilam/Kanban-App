import 'dart:async';

import '../../../../../domain/models/project/project.dart';
import '../../../../../domain/models/project/project_list.dart';
import '../../dio_client.dart';


class ProjectApi {
  // dio instance
  final DioClient _dioClient;

  // injecting dio instance
  ProjectApi(this._dioClient);

  /// Returns list of organization in response
  Future<ProjectList> getProjects(int organizationId) async {
    try {
      //final res = await _dioClient.get(Endpoints.getProjects);
      //return ProjectList.fromJson(res);

      // Fake API
      List<Project> projects = [];
      List<Project> filteredProjects = projects
          .where((item) => item.organizationId == organizationId)
          .toList();

      ProjectList organizationList = ProjectList(projects: filteredProjects);

      return await Future.delayed(const Duration(seconds: 2), () => organizationList);
    } catch (e) {
      rethrow;
    }
  }

  Future<Project> insertProject(
      int orgId, String title, String description) async {
    try {
      Project project = Project(
          id: DateTime.now().millisecond,
          title: title,
          description: description,
          organizationId: orgId);

      return await Future.delayed(const Duration(seconds: 2), () => project);
    } catch (e) {
      rethrow;
    }
  }
}
