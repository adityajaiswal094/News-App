import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "News App",
    home: MyApp(),
    // routes: {
    //   "/": (context) => const MyApp(),
    //   Routes.newspage: (context) => const NewsPage()
    // },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1),
              itemCount: repositories?.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.only(
                      top: 10, left: 10, right: 10, bottom: 5),
                  color: Colors.lightBlue[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Title: ${repositories?[index]['title']}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Stack(
                          alignment: AlignmentDirectional.topStart,
                          children: [
                            SizedBox(
                              height: 150,
                              width: 150,
                              child: Image.network(
                                repositories?[index]['urlToImage'],
                                fit: BoxFit.fill,
                              ),
                            ),
                            Text(
                              "URL: ${repositories?[index]['url']}",
                              maxLines: 1,
                            )
                          ]),
                      Text(
                        "Published At: ${repositories?[index]['publishedAt']}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Author: ${repositories?[index]['author']}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Content: ${repositories?[index]['content']}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Description: ${repositories?[index]['description']}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "H_ID: ${repositories?[index]['h_id']}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Source: ${repositories?[index]['source']}",
                        overflow: TextOverflow.ellipsis,
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
