// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "News App",
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // initHiveForFlutter();

    final HttpLink httpLink = HttpLink(
        "https://news-appdemo.herokuapp.com/v1/graphql",
        defaultHeaders: {
          "x-hasura-admin-secret":
              "oZpRYlgGDq2W9EpPWWffs7CGpEmoGS4TGJudWtdkaqrnZ6oMlzw4esrx0BPTvVmQ",
          "content-type": "application/json"
        });

    // debugPrint(httpLink.uri.toString());
    // debugPrint(httpLink.defaultHeaders.toString());

    // httpLink.defaultHeaders["x-hasura-admin-secret"] =
    // "oZpRYlgGDq2W9EpPWWffs7CGpEmoGS4TGJudWtdkaqrnZ6oMlzw4esrx0BPTvVmQ";
    // httpLink.defaultHeaders["content-type"] = "application/json";

    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
        GraphQLClient(link: httpLink, cache: GraphQLCache()));
    return GraphQLProvider(
      client: client,
      child: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    String readRepositories = """
      query getNews {
        news {
          title
          url
          publishedAt
          author
          content
          description
          h_id
          source
          urlToImage
        }
      }
    """;

    return Scaffold(
      appBar: AppBar(
        title: const Text("GraphQL Client"),
      ),
      body: Query(
          options: QueryOptions(document: gql(readRepositories)),
          builder: (QueryResult result,
              {VoidCallback? refetch, FetchMore? fetchMore}) {
            if (result.hasException) {
              return Text(result.exception.toString());
            }

            if (result.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (result.data == null) {
              return const Text("No data found");
            }

            List? repositories = result.data?['news'];

            // if (repositories == null) {
            //   return const Text('No repositories');
            // }

            return ListView.builder(
              itemCount: repositories?.length,
              itemBuilder: (BuildContext context, int index) {
                // final repository = repositories?[index];
                return Card(
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                        "Title: ${repositories?[index]['title']}",
                        maxLines: 3,
                      )),
                      Expanded(
                          child: Text(
                        "URL: ${repositories?[index]['url']}",
                        maxLines: 3,
                      )),
                      Expanded(
                        child: Text(
                          "Published At: ${repositories?[index]['publishedAt']}",
                          maxLines: 3,
                        ),
                      ),
                      Expanded(
                          child: Text(
                        "Author: ${repositories?[index]['author']}",
                        maxLines: 3,
                      )),
                      Expanded(
                          child: Text(
                        "Content: ${repositories?[index]['content']}",
                        maxLines: 3,
                      )),
                      Expanded(
                        child: Text(
                          "Description: ${repositories?[index]['description']}",
                          maxLines: 3,
                        ),
                      ),
                      Expanded(
                          child: Text(
                        "H_ID: ${repositories?[index]['h_id']}",
                        maxLines: 3,
                      )),
                      Expanded(
                          child: Text(
                        "Source: ${repositories?[index]['source']}",
                        maxLines: 3,
                      )),
                      Expanded(
                        child:
                            Image.network(repositories?[index]['urlToImage']),
                      )
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
