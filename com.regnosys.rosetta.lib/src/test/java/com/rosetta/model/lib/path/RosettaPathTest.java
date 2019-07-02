package com.rosetta.model.lib.path;

import static com.google.common.collect.ImmutableMap.of;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.core.Is.is;

import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.OptionalInt;
import java.util.stream.Collectors;

import org.junit.jupiter.api.Test;

import com.google.common.collect.ImmutableMap;
import com.rosetta.model.lib.path.RosettaPath.Element;
import com.rosetta.model.lib.path.RosettaPath.RosettaPathTree;

public class RosettaPathTest {
    private static final Element ELEMENT_A = Element.create("a", of());
    private static final Element ELEMENT_B = Element.create("b", of());
    private static final Element ELEMENT_C = Element.create("c", of());
    private static final Element ELEMENT_WITH_ID_1 = Element.create("x", of("id", "some-id-1"));
    private static final Element ELEMENT_WITH_ID_2 = Element.create("x", of("id", "some-id-2"));

    private static final Element ELEMENT_WITH_INDEX_1 = Element.create("y", OptionalInt.of(1), of());

    private static final Element ROOT_ELEMENT = Element.create("root", of());
    private static final RosettaPath PARENT_PATH = RosettaPath.createPath(ROOT_ELEMENT);

    @Test
    void createNewSubPathHasSameParent() {
        assertThat(PARENT_PATH.newSubPath(ELEMENT_A).getParent(), is(PARENT_PATH));
    }

    @Test
    void createNewSubPathHasSameElement() {
        assertThat(PARENT_PATH.newSubPath(ELEMENT_A).getElement(), is(ELEMENT_A));
    }

    @Test
    void parentExpression() {
        String path = PARENT_PATH.buildPath();
        assertThat(path, is("root"));
    }

    @Test
    void parentSingleChildExpression() {
        String path = PARENT_PATH.newSubPath(ELEMENT_A).buildPath();
        assertThat(path, is("root.a"));

    }

    @Test
    void multipleParentsExpression() {
        String path = PARENT_PATH
                .newSubPath(ELEMENT_A)
                .newSubPath(ELEMENT_B)
                .newSubPath(ELEMENT_C)
                .buildPath();
        assertThat(path, is("root.a.b.c"));
    }

    @Test
    void leafExpressionWithIndex() {
        String path = PARENT_PATH
                .newSubPath(ELEMENT_A)
                .newSubPath(ELEMENT_B)
                .newSubPath(ELEMENT_WITH_INDEX_1)
                .buildPath();
        assertThat(path, is("root.a.b.y(1)"));
    }

    @Test
    void leafExpressionWithId() {
        String path = PARENT_PATH
                .newSubPath(ELEMENT_A)
                .newSubPath(ELEMENT_WITH_ID_1)
                .newSubPath(ELEMENT_WITH_ID_2)
                .buildPath();
        assertThat(path, is("root.a.x[id=some-id-1].x[id=some-id-2]"));
    }

    @Test
    void intermediateAndLeafExpression() {
        String path = PARENT_PATH
                .newSubPath(ELEMENT_A)
                .newSubPath(ELEMENT_WITH_ID_2)
                .newSubPath(ELEMENT_WITH_INDEX_1)
                .buildPath();
        assertThat(path, is("root.a.x[id=some-id-2].y(1)"));
    }

    @Test
    void valueOfSimplePath() {
        String path = "root.a.b.c";
        assertThat(RosettaPath.valueOf(path), is(PARENT_PATH.newSubPath(ELEMENT_A).newSubPath(ELEMENT_B).newSubPath(ELEMENT_C)));
    }

    @Test
    void valueOfPathWithIndex() {
        String path = "root.a.y(1).c";
        assertThat(RosettaPath.valueOf(path), is(PARENT_PATH.newSubPath(ELEMENT_A).newSubPath(ELEMENT_WITH_INDEX_1).newSubPath(ELEMENT_C)));
    }

    @Test
    void valueOfPathWithId() {
        String path = "root.a.x[id=some-id-2].c";
        assertThat(RosettaPath.valueOf(path), is(PARENT_PATH.newSubPath(ELEMENT_A).newSubPath(ELEMENT_WITH_ID_2).newSubPath(ELEMENT_C)));
    }

    @Test
    void valueOfPathWithIdsAndIndex() {
        String path = "root.x[id=some-id-1].x[id=some-id-2].c.y(1)";
        assertThat(RosettaPath.valueOf(path), is(PARENT_PATH.newSubPath(ELEMENT_WITH_ID_1).newSubPath(ELEMENT_WITH_ID_2).newSubPath(ELEMENT_C).newSubPath(ELEMENT_WITH_INDEX_1)));
    }


    @Test
    void shouldReturnListOfAllElements() {
    	RosettaPath rosettaPath = PARENT_PATH.newSubPath(ELEMENT_A).newSubPath(ELEMENT_WITH_ID_2).newSubPath(ELEMENT_WITH_INDEX_1);
        List<Element> list = rosettaPath.allElements();

        assertThat(list.size(), is(4));
    }

    @Test
    void shouldCreatePathWhenHeadElementHasIndexValue() {
    	RosettaPath path = RosettaPath.createPathFromElements(Arrays.asList(ELEMENT_WITH_INDEX_1, ELEMENT_A));
        assertThat(path.buildPath(), is("y(1).a"));
    }
    
    @Test
    void shouldCreateTree() {
    	ImmutableMap<String,Object> pathsString = ImmutableMap.of("a.b.c", 1 ,"a.b.q", 2,"a.e.f",3);
    	Map<RosettaPath, Object> collect = pathsString.entrySet().stream().collect(Collectors.toMap(e->RosettaPath.valueOf(e.getKey()), e->e.getValue()));
    	RosettaPath.RosettaPathTree tree = RosettaPath.RosettaPathTree.treeify(collect);
    	assertThat(tree.getChildren().size(), is(1));
    }
    
    @Test
    void treeMatches() {
    	ImmutableMap<String,Object> pathsString = ImmutableMap.of("a.b.c", 1 ,"a.b.q", 2,"a.e.f",3);
    	Map<RosettaPath, Object> collect = pathsString.entrySet().stream().collect(Collectors.toMap(e->RosettaPath.valueOf(e.getKey()), e->e.getValue()));
    	RosettaPath.RosettaPathTree tree = RosettaPath.RosettaPathTree.treeify(collect);
    	RosettaPath toMatch = RosettaPath.valueOf("a.e.f");
    	assertThat(tree.matches(toMatch), is(3));
    }
    
    @Test
    void treeNameMatches() {
    	ImmutableMap<String,Object> pathsString = ImmutableMap.of("a.b.c", 1 ,"a.b.q", 2,"a.e(1).f",3);
    	Map<RosettaPath, Object> collect = pathsString.entrySet().stream().collect(Collectors.toMap(e->RosettaPath.valueOf(e.getKey()), e->e.getValue()));
    	RosettaPath.RosettaPathTree tree = RosettaPath.RosettaPathTree.treeify(collect);
    	RosettaPath toMatch = RosettaPath.valueOf("a.e(2).f");
    	List<RosettaPathTree> matches = tree.matches(toMatch, Comparator.<Element, String>comparing(e->e.getPath()));
		assertThat(matches.size(), is(1));
		matches.get(0).toString();
		assertThat(matches.get(0).getValue(), is (3));
    }
    
    @Test
    void treeNameDoesntMatch() {
    	ImmutableMap<String,Object> pathsString = ImmutableMap.of("a.b.c", 1 ,"a.b.q", 2,"a.e(1).f",3);
    	Map<RosettaPath, Object> collect = pathsString.entrySet().stream().collect(Collectors.toMap(e->RosettaPath.valueOf(e.getKey()), e->e.getValue()));
    	RosettaPath.RosettaPathTree tree = RosettaPath.RosettaPathTree.treeify(collect);
    	RosettaPath toMatch = RosettaPath.valueOf("a.z(2).f");
    	assertThat(tree.matches(toMatch, Comparator.<Element, String>comparing(e->e.getPath())).size(), is(0));
    }

    @Test
    void shouldMatchPathEndsWith() {
    	RosettaPath p1 = RosettaPath.valueOf("p.q.r.s.t.u.v.w.x.y.z");
    	RosettaPath p2 = RosettaPath.valueOf("u.v.w.x.y.z");
    	assertThat(p1.endsWith(p2), is(true));
    }
    
    @Test
    void shouldNotMatchPathEndsWith() {
    	RosettaPath p1 = RosettaPath.valueOf("p.q.r.s.t.u.v.w.x.y.z");
    	RosettaPath p2 = RosettaPath.valueOf("diff.v.w.x.y.z");
    	assertThat(p1.endsWith(p2), is(false));
    }
    
    @Test
    void pathWildcard() {
    	RosettaPath p1 = RosettaPath.valueOf("p.q.r.s.t.u.v.w.x.y.z");
    	RosettaPath p2 = RosettaPath.valueOf("v.w.*.y.z");
    	assertThat(p1.endsWith(p2), is(true));
    }
}
