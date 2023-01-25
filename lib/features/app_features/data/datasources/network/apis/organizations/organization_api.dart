import 'dart:async';

import '../../../../../domain/models/organization/organization.dart';
import '../../../../../domain/models/organization/organization_list.dart';
import '../../dio_client.dart';


class OrganizationApi {
  // dio instance
  final DioClient _dioClient;

  // injecting dio instance
  OrganizationApi(this._dioClient);

  /// Returns list of organization in response
  Future<OrganizationList> getOrganizations() async {
    try {
      //final res = await _dioClient.get(Endpoints.getOrganizations);
      //return OrganizationList.fromJson(res);

      // Fake API
      List<Organization> organizations = [
        Organization(
          userId: 1,
          id: 1,
          title: "Personal Workspace",
          description: "Your personal workspace",
        ),
      ];

      OrganizationList organizationList =
          OrganizationList(organizations: organizations);

      return await Future.delayed(Duration(seconds: 1), () => organizationList);
    } catch (e) {
      rethrow;
    }
  }

  Future<Organization> insertOrganizations(String title, String description) async {
    try {
      //final res = await _dioClient.post(Endpoints.getOrganization + organization.id.toString());
      //return OrganizationList.fromJson(res);

      Organization org = Organization(
          id: DateTime.now().millisecond,
          title: title,
          description: description,
          userId: 1);

      return await Future.delayed(const Duration(seconds: 2), () => org);
    } catch (e) {
      rethrow;
    }
  }
}
